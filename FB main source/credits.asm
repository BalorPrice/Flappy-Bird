;-------------------------------------------------------
; CREDITS

;-------------------------------------------------------
credits.text.green:										; Credits texts split into different colours
				dm "Program:"
				db cr
				dm "Playtesting++:"
				db cr
				dm "Original game:"
				db cr,cr
				dm "Music:"
				db cr,cr,cr,cr,cr
				dm "Made with:"    
				db eof

credits.text.white:
				db cr,cr,cr,cr,cr
				db quote
				dm "George pt ll"
				db quote,cr
				dm "Protracker ll"
				db cr
				dm "Compiler/player"
				db cr,cr,cr
				dm "pyZ80"
				db cr
				dm "SimCoupe"
				db cr
				dm "Aseprite"
				db eof

credits.text.brown:
				dm "Howard Price"
				db cr
				dm "David Ledbury"
				db cr
				dm ".GEARS Studio"
				db cr,cr,cr
				dm "Maxo"
				db cr
				dm "Jarek Burczynski"
				db cr
				dm "Andrew Collier"
				db cr,cr,cr
				dm "Andrew Collier"
				db cr
				dm "Simon Owen"
				db cr
				dm "Igara Studio"
				db eof
				

credits.cols.white:										; Colourisation tables for each of the font colours
				db 0,1,2,3,4,5,6,7,8,9,light_brown,0,0,0,0,white
credits.cols.brown:
				db 0,0,0,0,0,0,0,0,0,0,light_brown,0,0,0,0,orange
credits.cols.green:
				db 0,0,0,0,0,0,0,0,0,0,dark_green,0,0,0,0,light_green
				

credits.print_list:										; List of tables, positions and text sources for credits text
				dw credits.cols.green, &2a30, credits.text.green
				dw credits.cols.white, &2a34, credits.text.white
				dw credits.cols.brown, &2a85, credits.text.brown
				dw eof

credits.on:					db No
credits.mode:				db credits.mode.idle		; 
credits.mode.idle:			equ 0						; No credits - just logo displayed, bouncing
credits.mode.init:			equ -1
credits.mode.move_logo:		equ -2
credits.mode.print_text:	equ -3
credits.mode.copy_down:		equ -4
credits.mode.display:		equ -5
credits.mode.play_game:		equ -6

credits.icon.music.x:		equ &ce						; Music icon position
credits.icon.music.y:		equ 5
credits.icon.music.age:		db 0
	
credits.icon.sfx.x:			equ &bc						; SFX icon position
credits.icon.sfx.y:			equ 5
credits.icon.sfx.age:		db 0
				
credits.timer:				dw 50 * 15

;-------------------------------------------------------
credits.update:
; Update credits state machine, running in display module
				ld a,(credits.mode)
				cp credits.mode.play_game
				ret z
	
				cp credits.mode.idle
				jp z,credits.idle
				cp credits.mode.init
				jp z,credits.init
				cp credits.mode.move_logo
				jp z,credits.move_logo
				cp credits.mode.print_text
				jp z,credits.print_text
				cp credits.mode.copy_down
				jp z,credits.copy_down
				cp credits.mode.display
				jp z,credits.display
				ret

;-------------------------------------------------------
credits.idle:
				ld hl,(credits.timer)
				dec hl
				ld (credits.timer),hl
				ld a,h
				or l
				or a
				ret nz
				
				ld hl,50 * 15
				ld (credits.timer),hl
				
	@update_state:
				ld a,credits.mode.init
				ld (credits.mode),a
				ret
				
;-------------------------------------------------------
credits.init:
; Remove the space icon
	@kill_space_icon:
				ld ix,(attract.space.sprite_base)
				call sprite.killIX
				ld hl,0
				ld (attract.space.sprite_base),hl
				
	@update_state:										; Set to next state
				ld a,credits.mode.move_logo
				ld (credits.mode),a
				ret
				
;-------------------------------------------------------
credits.move_logo:
; Logo and bird will move up screen, wait until the height is correct
				ld a,(hero.y + 1)
				cp 5
				ret nz

	@update_state:
				ld a,credits.mode.print_text
				ld (credits.mode),a
				ret
				
;-------------------------------------------------------
credits.print_text:
	@paging:
				in a,(LMPR)
				ld ( @+rest_lo + 1),a
				ld a,ScreenPage3 + ROMOut
				out (LMPR),a
				
				ld ix,credits.print_list
				ld b,3
	@loop:
				push bc
				push ix
				
				ld l,( ix + 0)
				ld h,( ix + 1)				
				call font.set_colourisedHL
				ld e,( ix + 2)
				ld d,( ix + 3)
				ld l,( ix + 4)
				ld h,( ix + 5)
				call font.print_stringHLDE
				
				pop ix
				ld bc,6
				add ix,bc
				pop bc
				djnz @-loop
	@end:
				ld a,credits.mode.copy_down
				ld (credits.mode),a
				ld a,&26
				ld ( @+copy_down_tally + 1),a
	@paging:
		@rest_lo: ld a,0
				out (LMPR),a
				ret

;-------------------------------------------------------
credits.copy_down:
; Copy printed credits onto display screens
	@copy_down_tally: ld a,&26
				for 2,inc a
				cp map.y.bottom + 10
				jr z,@+update_state
				
				ld ( @-copy_down_tally + 1),a
				call jump.credits.copy_downA
				ret
				
	@update_state:
				ld a,credits.mode.display
				ld (credits.mode),a
				ret

;-------------------------------------------------------
credits.display:
				ld hl,(credits.timer)
				dec hl
				ld (credits.timer),hl
				ld a,h
				or l
				or a
				ret nz
				
				ld hl,50 * 15
				ld (credits.timer),hl
				call attract.kill_sprites
				
	@update_state:
				ld de,game.attract.prep1
				ld (game.state + 1),de
				ld a,credits.mode.idle
				ld (credits.mode),a
				ret

;-------------------------------------------------------

;=======================================================
;-------------------------------------------------------
credits.check_sound:
; Check for F9 and F8 for toggling music and SFX
				ld a,(keys.processed)
				bit F9,a
				jr nz,credits.icon.music.toggle
				bit F8,a
				jr nz,credits.icon.sfx.toggle
				ret

credits.icon.music.toggle:
; If F9 is pressed, toggle music on/off
	@toggle_music:										; Change state
				ld a,(music.on)
				xor &ff
				ld (music.on),a
				ret

credits.icon.sfx.toggle:
				ld a,(sfx.on)
				xor &ff
				ld (sfx.on),a			
				ret

;-------------------------------------------------------
