;-------------------------------------------------------
; KEYS READING AND INTERPRETING
				
;-------------------------------------------------------
				include "redefine.asm"				; Not needed for this build!

;-------------------------------------------------------
key_init_repeat_speed: 	db 15							; frames before key repeat starts
key_repeat_speed: 		db 15							; frames between repeats once started - very slow so flapping needs extra taps

Fire:					equ 0							; Bits set for each keypress, functionally sorted
Up:						equ 1
Down:					equ 2
Right:					equ 3
Left:					equ 4
Escape:					equ 5
F8:						equ 6
F9:						equ 7
		
keys.curr:				db 0							; Last read current keypresses
keys.prev:				db 0							; Previous scan current keypresses
keys.processed:			db 0 							; Current key functions (ie key repeats processed)

keys.tally_array: 		for 8,db 0						; tallies of amount of frames each key held down
keys.repeat_types: 		db 0

keys.redef:				db 48,0,0,41,40,16,8,56			; Redefined keys, read by Steve Taylor's routine

keys.mode:				db keys.mode.normal
keys.mode.normal:		equ -1							; Game input mode - no key re
keys.mode.demo:			equ -2
keys.mode.typing:		equ -3

;-------------------------------------------------------
keys.input:
; Collect keys and overlay them as separate inputs all working together
@age_keys:
				ld a,(keys.curr)
				ld (keys.prev),a
				cpl
				ld e,a

				call keys.collect						; Read keys
@process_and_store:
				ld (keys.curr),a						; store D as current
				ld (keys.processed),a					; Store as processed by 
				
				ld a,(keys.mode)						; If in typing mode, process for key repeats
				cp keys.mode.typing
				call z,keys.process
				ret

;-------------------------------------------------------
keys.collect:
; Return currently pressed keys in A and D.
@f9f8:
				ld bc,&fbf9
				in a,(c)
				cpl
				and %11000000
				ld d,a
@escape:
				ld bc,&f7f9
				in a,(c)
				cpl
				and %00100000
				or d
				ld d,a

@read_redefined:										; Make a loop for each of the keys in the redef list
				push de
				ld hl,keys.redef
				call redefine.k_scanHL
				pop de
				ld a,c
				or d
				or a
				ret nz									; If a key pressed here, immediately process

@directional:											; for movement, use joystick or cursor keys
	@joystick:
				ld bc,&effe
				in a,(c)
				cpl
				and %00011111
				or d									; ! only needed because redefined is currently commented out
				ld d,a

	@cursor_keys:
		@up_down:
				ld bc,&fffe
				in a,(c)
				cpl
				and %00000110
				or d
				ld d,a
		@left:
				in a,(c)
				cpl
				and %00001000
				rla
				or d
				ld d,a
		@right:
				in a,(c)
				cpl
				and %00010000
				rra
				or d
				ld d,a

@fire:													; Fire buttons F0 and shift
	@f0:
				ld bc,&dff9
				in a,(c)
				cpl
				and %10000000
				rlca
				or d
				ld d,a
	@shift:
				ld bc,&fefe
				in a,(c)
				cpl
				and %00000001
				or d
				ld d,a

@pickup:												; buttons fullstop and symbol
	; @fullstop:
				; ld bc,&7ff9
				; in a,(c)
				; cpl
				; and %01000000
				; add a
				; or d
				; ld d,a
	; @symbol:
				; ld bc,&7ffe
				; in a,(c)
				; cpl
				; and %00000010
				; for 2,rrca
				; or d
				; ld d,a
				
	; 
				ret

;-------------------------------------------------------
keys.process:
; Translate keys from physical keypresses into repeating keydown events
				ld hl,keys.tally_array					; list of tallies how long each key's been down
				ld a,(keys.curr)		
				ld c,a									; current physical state of each key
				ld a,(keys.repeat_types)		
				ld d,a									; bitstates whether key is in start or repeat phase
				ld e,0									; prep output
				ld b,8									; loop count
@key_loop:		
				rr c		
				jp nc,@+key_up		
		
	@key_downBC:										; If key pressed
		@increase_tally:								; Update tally for this key
				inc (hl)		
		@check_new:										; Check whether new keypress, ie:
				bit 0,d									; ... In start state
				jp nz,@+check_repeat_type		
				ld a,(hl)								; ... tally is 1 (just updated, this frame)
				cp 1		
				jp z,@+set_on							; If so, set keypress on directly
		@check_repeat_type:								; Set A to either starting or repeating delay value
				ld a,(key_repeat_speed)		
				bit 0,d		
				jp nz,@+check_delay		
				ld a,(key_init_repeat_speed)		
			@check_delay:								; check how long this key pressed down
				cp (hl)		
				jp nc,@+next_key						; If less than repeat check, quit
			@reset_tally:								; Else reset timer
				ld (hl),0		
			@set_keystate:								; Set phase to repeat
				set 0,d		
		@set_on:		
				set 0,e									; set keypress to down
				jp @+next_key		
		
	@key_up:											; If key not pressed
		@reset_key_tally:								; reset keydown tally to 0
				ld (hl),0		
		@reset_keystate:								; set keystate to start phase
				res 0,d

	@next_key:
				rrc e
				rrc d
				inc hl
				djnz @key_loop

				ld a,e
				ld (keys.processed),a
				ld a,d
				ld (keys.repeat_types),a
				ret
		
;-------------------------------------------------------
		