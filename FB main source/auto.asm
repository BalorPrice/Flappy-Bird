;-------------------------------------------------------
; FLAPPY BIRD IN A DAY*

; *Okay, 2 weeks.

;-------------------------------------------------------
; Entry point
				dump 1,0
				autoexec								; Include this line to create auto-running code from pyZ80
				org &8000

auto.start:
				di
	@set_stack:
				ld sp,@+stack
				jp main.start

				ds &40
@stack:
auto.main.stack:
				dm "** FLAPPY BIRD **  FREEWARE  by tobermory@cookingcircle.co.uk  v1.01 "
int.main.stack: 
				ds 1
				
;-------------------------------------------------------
; MODULES
				include "house.asm"						; Housekeeping routines
				include "compile equates.asm"			; Equates for compiling code/self-modifying code
				include "maths.asm"		
				include "keys.asm"						; keyboard reading
				include "font.asm"						; Font printing
				include "game.asm"						; Main game logic state machine
				include "display.asm"					; Display state machine
				include "interrupts.asm"				; Interrupts management
				include "sprite.asm"					; Moving sprites
				include "gfx.asm"						; Standard bitmap graphics printing
				include "hero.asm"						; Main character movement
				include "attract.asm"					; Attract sequence logo
				include "scoreboard.asm"				; End game scorecard
				include "credits.asm"
				include "pipe.asm"
				include "grass.asm"						; Grass animation
				include "jump.asm"						; Graphics routines moved under both display screens
				include "collider.asm"					; Collision detection
				include "hud.asm"						; control panel printing 
				include "music.asm"						; Music module
				include "sfx.asm"						; Sound effects

;-------------------------------------------------------
; GLOBAL VARIABLES

frame_sync.on:	equ On									; Wait for frame interrupt before displaying next display frame?

auto.512k:		db 0									; Yes/Success if 512K is found
sfx.on:			db On
music.on:		db On									; Set to on if music can be played
demo.mode.on:	db Off									; See sfx module.  If attract sequence is 'playing' then no sound effects

compile.page:	db GfxPage2								; Page and current address of next free byte to compile
compile.addr:	dw &8000

;-------------------------------------------------------
; MAIN LOOP
main.start:
				call main.test_512K
				call main.setup							; One-off prep code when game loaded
	@init_state:										; Set initial state for attract sequence
				ld hl,int.ll.off						; Set line interrupts manager to just frame interrupt
				call int.ll.installHL
				
				ld hl,game.attract.prep1				; Game state machine runs on frame interrupt
				ld a,(auto.512K)
				or a
				jr z,@+skip
				ld hl,game.prep_512k_only
		@skip:
				ld de,disp.game							; Display state machine runs in non-interrupt time
				call int.onHLDE
main.disp.loop:											; Main loop for display code only, runs in non-interrupt time
	@wait_frame:										; Wait until at least one frame has elapsed
				ld a,(int.new_frames_elapsed.live)
				or a
				jp z,@-wait_frame
				ld (int.new_frames_elapsed),a			; Store elapsed frames for display update
				xor a									; Reset live count of elapsed frames for the interrupt routine
				ld (int.new_frames_elapsed.live),a
				
	disp.state:	call 0									; Display driver state machine, see display.asm

	@reset_frame_count:
				xor a
				ld (int.new_frames_elapsed),a	

				jp main.disp.loop

;-------------------------------------------------------
game.state:		jp 0									; Main game state machine call.  Everything called here in running in interrupt time.

;-------------------------------------------------------
main.setup:
; One-time only setup routines.
				call house.dbuf.set						; Set up double buffer
				ld a,8
				call house.palette_offA	
				ld a,dark_grey_border
				out (BorderReg),a
				ld a,dark_grey * &11
				call house.clear_screensA
				call jump.prep							; Prepare jump routines to sit under both screens
				call jump.prep_scroll					; Prescroll sprites for pixel accuracy
				call pipe.cleaner.install				; Install pipe quick cleaner routine under screen3
				call int.setup
				call comp.create						; Compile qprint sprite routines
				ld a,dark_grey * &11
				call house.clear_screensA
				
				ld a,keys.mode.typing					; Set keyboard routine to process for key repeats, not continuous input
				ld (keys.mode),a
				call font.set_masked					; Set font print mode to print masked
				call sprite.slots.init_all				; Init 
				ld a,On
				ld (int.sprites.on),a
				
				ld a,music.george
				call music.setA 
				ret
	
;-------------------------------------------------------
main.test_512K:
; Test if 256K expansion is present. Auto.512k stores 0 on success, -1 on failure
	@paging:											; Set to a high page
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,&10 + ROMOut
				out (LMPR),a

				ld a,Failure							; Assume failure
				ld (auto.512k),a
				xor a
				ld b,a									; 256 loops to check
				ld hl,0
	@loop:
				ld (hl),a								; load a value
				cp (hl)									; Check it has been retained
				jr nz,@+paging							; If not, skip out immediately
				djnz @-loop

	@success:
				ld a,Success
				ld (auto.512k),a
	@paging:
	@rest_lo:	ld a,0
				out (LMPR),a
				ret
				
;-------------------------------------------------------
				
;=======================================================
auto.end:
auto.len:		equ auto.end - auto.start

print "-----------------------------------------------------------------------------------"
print "auto.start      ", auto.start, 		" auto.end   ", auto.end, 		" auto.len    ", auto.len
print "jump.start      ", jump.start, 		" jump.end   ", jump.end, 		" jump.len    ", jump.len
print "int.start       ", int.start, 		" int.end    ", int.end, 		" int.len     ", int.len
print "gfx.start       ", gfx.start, 		" gfx.end    ", gfx.end, 		" gfx.len     ", gfx.len
print "-----------------------------------------------------------------------------------"
