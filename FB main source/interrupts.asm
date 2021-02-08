interrupts.mod:
;-------------------------------------------------------
; INTERRUPTS

; Gameplay runs on frame interrupt at 50hz exactly.  This includes game logic, key scanning, Music and sound effects playing.  The display update state machine runs in non-interrupts in all the remaining CPU time.  If the game gets too busy then the sprites will drop update rate but it won't affect gameplay at all.

int.base:						equ &60					; Start of jump table /256 = 24576, under screen
int.handler_addr:				equ &61					; Start of handler routine /257 = 32639, 129 bytes spare

int.new_frames_elapsed.live:	db 0					; Amount of 1/50ths second elapsed since last sprite frame displayed (real time)
int.new_frames_elapsed:			db 0					; number of frames elapsed since last display update
int.sprites.on:					db On					; Main control whether sprites are to be printed or not

int.next:						dw 0
int.jump:						dw 0
int.reset:						dw 0

int.white_toggle:				db 127
int.block_pal_set.on:			db On

;-------------------------------------------------------
int.setup:
; Setup interrupt mode.  This uses IM2 to jump beneath the screen.
	@set_mode:											; Set mode and jump table base
				im 2
				ld a,int.base
				ld i,a
				call @+install							; Install jump table and routine under screen 1
				call house.dbuf.swap
				call @+install							; Install under screen 2
				call house.dbuf.swap
				
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,ScreenPage3 + ROMOut
				out (LMPR),a
				call @+install
		@rest_lo: ld a,0
				out (LMPR),a
				ret

@install:
	@make_jump_table:									; IM2 jumps to random entry in this table
				ld h,int.base
				ld l,0
				ld d,h
				ld e,1
				ld bc,&100
				ld (hl),int.handler_addr				; Interrupt handler sits at int.handler_addr * 257
				ldir
	@move_handler:										; Move handler into correct position
				ld hl,int.handler.src
				ld de,int.start
				ld bc,int.len
				ldir
				ret
				
;-------------------------------------------------------
int.ll.installHL:
; Install linked list for line interrupts at HL
				call @+install
				call house.dbuf.swap
				call @+install
				call house.dbuf.swap
				ret
				
@install:
				push hl

		@set_reset_val:
				ld (int.reset),hl
		@set_line:										; set line address of next routine
				ld a,(hl)
				out (StatusReg),a
				inc hl
		@set_rout:										; set routine address for this line int
				ld c,(hl)
				inc hl
				ld b,(hl)
				ld (int.jump),bc
				inc hl
		@set_next:										; store address of next line int entry in table
				ld (int.next),hl
				
				pop hl
				ret

;-------------------------------------------------------
int.onHLDE:
; Turn interrupts on:
; 	HL: first interrupt state machine routine address
; 	DE: Display driver (non-interrupt) routine address
	@reset_states:
				ld (game.state + 1),hl
				ld (disp.state + 1),de
	@reset_frame_count:
				xor a
				ld (int.new_frames_elapsed),a
				ld (int.new_frames_elapsed.live),a

				ei
				ret

;-------------------------------------------------------

int.handler.src:
;=======================================================
; Interrupt handler is copied under both screens

				org int.handler_addr * &0101

int.start:
				ld ( @+rest_sp + 1),sp
				ld sp,int.stack.tiny
				push af									; Store A and flags immediately
				
				in a,(StatusReg)						; Save status reg for checking what called us
				ld (int.status + 1),a
	@paging:											; Page in main page 
				in a,(HMPR)
				ld ( @+rest_hi + 1),a
				ld a,MainPage
				out (HMPR),a
	@set_stack:
				ld sp,int.main.stack

				push bc
				push hl
			
				ld hl,(int.jump)						; Call interrupt routine
				ld ( @+jump_addr + 1),hl
	@jump_addr:	call 0

	@update_line_int:									; get address of linked list entry for next routine
				ld hl,(int.next)
				ld a,(hl)
				inc hl
				ld h,(hl)
				ld l,a						

	int.set:
		@set_line:										; set line address of next routine
				ld a,(hl)
				out (StatusReg),a
				inc hl
		@set_rout:										; set routine address for this line int
				ld c,(hl)
				inc hl
				ld b,(hl)
				ld (int.jump),bc
				inc hl
		@set_next:										; store address of next line int entry in table
				ld (int.next),hl

				pop hl
				pop bc
				
	@rest_hi:	ld a,0
				out (HMPR),a
	@rest_af:	
				ld sp,int.stack.tiny - 2
				pop af
	@rest_sp:	ld sp,0
				ei
				ret

				ds 2
int.stack.tiny:											; A very short stack for storing AF only

			if defined (DEBUG)							; Token spacer
				nop
			endif
			
;-------------------------------------------------------
int.frame_update:
; Frame interrupt routine, running timing-specific routines:  game logic, sound/music and key scanning.
	@check_int:											; Make sure this is the frame interrupt
	int.status: ld a,0
				bit FrameIntBit,a
				jp z,@+save_regs
		@reset_int_manager:								; If not, reset to start properly next time
				ld hl,(int.reset)
				ld (int.next),hl
				ret

	@save_regs:											; Only called every 1/50th second, so save everything and leave coding flexible
				push de
				push ix
				push iy
				exx
				ex af,af'
				push af
				push bc
				push de
				push hl
				exx
				ex af,af'

				call music.play							; Play music
				call sfx.update.out						; Overload music output with sound effects where needed
				call keys.input							; Read keys
				call maths.rand							; Update the PRNG

				call game.state							; Main game state machine call

	@inc_frame_delay:									; Update amount of frames since last game frame
				ld hl,int.new_frames_elapsed.live
				inc (hl)
	@rest_regs:
				ex af,af'
				exx
				pop hl
				pop de
				pop bc
				pop af
				ex af,af'
				exx
				pop iy
				pop ix
				pop de
				ret

;-------------------------------------------------------
; Linked lists of line interrupts data

int.ll.line.os:	equ 0									; Offsets within entry for line number, -1 for frame
int.ll.addr.os:	equ 1									; Address of maintenance routine
int.ll.next.os:	equ 3									; Address of next entry
int.ll.len:		equ int.ll.next.os + 2

int.ll.off:
; Null list of just one entry
				db -1
				dw int.frame_update,int.ll.off
				
;-------------------------------------------------------

int.end:
int.len:		equ int.end - int.start

;=======================================================

				org int.handler.src + int.len

;-------------------------------------------------------
