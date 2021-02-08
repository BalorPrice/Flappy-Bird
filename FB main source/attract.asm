;-------------------------------------------------------
; ATTRACT MODE

;-------------------------------------------------------
				include "scrolly.asm"					; Credits scroller on bottom of screen

;-------------------------------------------------------
attract.logo.x.start:			equ 70					; Coords for main logo to hover around
attract.logo.y.start:			equ &0032

attract.gover.x.start:			equ &0050				; Coords for game over logo
attract.gover.y.start:			equ &0000
attract.gover.y:				dw 0					; 50hz update of actual position of game over in 8.8 format
attract.gover.y.mom:			dw 0					; Momentum, down is positive
attract.gover.bounce.y:			equ &0028
attract.gover.timer:			dw 0					; Countdown before game over state flips back to attract with logo
attract.gover.time:				equ &0030

attract.logo.wobble_spd: 		equ 7					; Speed to travel through sine table
attract.logo.sin.os:			db 0					; Current angle through sine table (0-255)

attract.logo.sprite_base:		dw 0					; Sprite slot addresses of each element
attract.bird.sprite_base:		dw 0
attract.space.sprite_base:		dw 0
attract.gover.sprite_base:		dw 0

attract.bgd.cols:	db &80,sky_blue * &11, &22,white * &11, &0a,light_green * &11
					db &01,brown * &11, &01,yellow * &11, &03,mid_green * &11, &01,dark_green * &11, &02
					db light_brown * &11, &0c,orange * &11, &ff

attract.print_screen.req:		db Off					; Request flag for display to print full attract screen

;=======================================================
; MAIN BACKGROUND PRINTER

;-------------------------------------------------------
attract.print_screen.set:
				ld a,On
				ld (attract.print_screen.req),a
				ret
				
;-------------------------------------------------------
attract.print_screen:
; Print background and start logo as a sprite
	@check_requested:									; Check interrupts have requested this operation
				ld a,(attract.print_screen.req)
				cp Off
				ret z
				
				call attract.print_background
				call house.dbuf.swap
				call attract.print_background
				call house.dbuf.swap
				call jump.save_screen					; Static third screen for background items
				call house.set_curr_palette
				
				ld a,Off
				ld (attract.print_screen.req),a
				ret

attract.print_background:
	@clear_sky_clouds:									; Clear play area with sky blue and white for clouds
				ld hl,0
				ld de,1
				
				ld ix,attract.bgd.cols
	@loop:
				ld a,(ix)
				cp -1
				jr z,@+print_clouds
				
				ld b,a
				inc ix
				ld a,(ix)
				inc ix
				call @y_loopA
				jr @-loop
				
	@print_clouds:										; Print loop of clouds along centre
				ld a,sprite.frames.clouds
				ld de,&7620
				ld b,4
		@loop:
				push bc
				push af
				push de
				call jump.print_frameADE				; Frame printer clips to the right if necessary
				pop de
				ex de,hl
				ld bc,60								; Odd width, seems to balance quite well
				add hl,bc
				ex de,hl
				pop af
				pop bc
				djnz @-loop

	@print_scenery:										; Print loop of clouds along centre
				ld a,sprite.frames.scenery
				ld de,&8620
				ld b,5
		@loop:
				push bc
				push af
				push de
				call jump.print_frameADE				; Frame printer clips to the right if necessary
				pop de
				ex de,hl
				ld bc,42								; Odd width, seems to balance quite well
				add hl,bc
				ex de,hl
				pop af
				pop bc
				djnz @-loop
	@set_border:
				ld a,dark_grey_border
				out (BorderReg),a
				ret

	@y_loopA:
				push bc
				
				ld (hl),dark_grey * &11					; 32 pixels of black
				ld bc,&10
				ldir
				ld (hl),a								; 192 pixels of sky / cloud
				ld bc,&60
				ldir
				ld (hl),dark_grey * &11					; 32 pixels of black
				ld bc,&10 - 1
				ldir
				inc hl
				inc de 
				
				pop bc
				djnz @-y_loopA
				ret

;=======================================================
; ATTRACT MODE FLOATING LOGO

;-------------------------------------------------------
attract.start_logo:
; Set attract logo sprites
@main_logo:
				call sprite.ll.append					; Add a sprite
				ld (attract.logo.sprite_base),ix
	@set_routs:											; Set print, update, clear routines
				ld hl,jump.qprintIX
				ld de,attract.logo.update				; Update y position from sine table
				ld bc,jump.sprite.replace_bgdIX
				call sprite.set_routsIXHLDEBC
	@set_pos:											; Set start position
				ld hl,attract.logo.x.start
				ld de,attract.logo.y.start
				call sprite.set_posIXHLDE
	@set_anim:											; Set start animation
				ld a,sprite.anim.logo
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off		; Set visible

@bird_icon:												; Print bird to right of logo
				call sprite.ll.append			
				ld (attract.bird.sprite_base),ix
	@set_routs:									
				ld hl,jump.qprintIX
				ld de,attract.bird.update		
				ld bc,jump.sprite.replace_bgdIX
				call sprite.set_routsIXHLDEBC
	@set_pos:									
				ld hl,attract.logo.x.start + &068
				ld de,attract.logo.y.start
				call sprite.set_posIXHLDE
	@set_anim:									
				ld a,sprite.anim.hero.flap
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off
@reset_wobble:
				xor a
				ld (attract.logo.sin.os),a
				
@space_icon:											; Print button to press space
				call sprite.ll.append			
				ld (attract.space.sprite_base),ix
	@set_routs:									
				ld hl,jump.qprintIX
				ld de,0
				ld bc,jump.sprite.replace_bgdIX
				call sprite.set_routsIXHLDEBC
	@set_pos:									
				ld hl,&0070
				ld de,&009b
				call sprite.set_posIXHLDE
	@set_anim:									
				ld a,sprite.anim.space
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off
				ret

;-------------------------------------------------------
attract.logo.update:
; Sprite updater: Set position of logo according to a sine wave
				ld a,(credits.mode)
				cp credits.mode.idle
				jr nz,@+move_up
	@get_angle:
				ld a,(attract.logo.sin.os)				; Sine offset updated in game.attract.run at 50hz
				ld l,a
				ld h,maths.sin_table / &100
				ld a,(hl)								; Get Sine value in 8.8 format
				inc h									; Sine table stored vertically, aligned to MSB address boundary
				ld h,(hl)
				ld l,a
				for 3, add hl,hl						; Multiply movement to 8 pixels up/down for wobble
				
				ld de,attract.logo.y.start * &100		; Add to central logo position
				add hl,de
				bit 7,l
				ld ( ix + sprite.yH.os),h
				ld a,h
				ld (hero.y + 1),a
				ret
				
	@move_up:											; If credits screen displayed, move upward to top position
				ld a,(hero.y + 1)
				cp 5
				ret z

				ld hl,(hero.y)
				ld e,l
				ld d,h
				srl d
				rr e
				srl d
				rr e
				srl d
				rr e
				and a
				sbc hl,de
				ld (hero.y),hl
				ld ( ix + sprite.yH.os),a
				ret

;-------------------------------------------------------
attract.bird.update:
; Same as logo update, but Y value slightly lower to line up
				
				ld a,(credits.mode)
				cp credits.mode.idle
				jr z,@+get_angle
				cp credits.mode.play_game
				jr nz,@+move_up
	@check_credits:										; If credits currently set on, don't update position
				ld a,(credits.on)
				cp On
				ret z
	@get_angle:
				ld a,(attract.logo.sin.os)			
				ld l,a
				ld h,maths.sin_table / &100
				ld a,(hl)							
				inc h								
				ld h,(hl)
				ld l,a
				for 3, add hl,hl					
				
				ld de,(attract.logo.y.start + 4) * &100
				add hl,de
				ld ( ix + sprite.yH.os),h
				ret
				
	@move_up:
				ld a,(hero.y + 1)
				add 4
				ld ( ix + sprite.yH.os),a
				ret

;-------------------------------------------------------
attract.logo_wobble.update:
; Update position of wobble - called from game.attract.run
	@update_sine_wobble:
				ld a,(attract.logo.sin.os)
				add attract.logo.wobble_spd
				ld (attract.logo.sin.os),a
				ret

;-------------------------------------------------------
attract.kill_sprites:
; Remove sprites before starting real game
	@kill_logo:
				ld ix,(attract.logo.sprite_base)
				call sprite.killIX
	@kill_bird:
				ld ix,(attract.bird.sprite_base)
				call sprite.killIX
	@kill_space:
				ld ix,(attract.space.sprite_base)
				ld a,ixh								; Test this icon exists before trying to kill it
				or ixl
				or a
				ret z
				call sprite.killIX				
				ret

;=======================================================
; GAME OVER LOGO SPRITE
			
;-------------------------------------------------------
attract.gover.print:
; Start game over logo as a sprite
	@add_sprite:										; !! .insert_before is buggy but seems to be working here.  Very odd.
				ld ix,(sprite.ll.first)
				call sprite.ll.insert_beforeIX
				ld (attract.gover.sprite_base),ix
	@set_routs:											; Set print, update, clear routines
				ld hl,jump.qprintIX
				ld de,attract.gover.sprite.updateIX
				ld bc,jump.sprite.replace_bgdIX
				call sprite.set_routsIXHLDEBC
	@set_sprite_pos:									; Set start position
				ld hl,attract.gover.x.start
				ld de,attract.gover.y.start
				ld (attract.gover.y),de
				call sprite.set_posIXHLDE
	@set_anim:											; Set start animation
				ld a,sprite.anim.gover
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off		; Set visible
				
	@reset_positions:									; Set ideal Y data
				ld hl,0	
				ld (attract.gover.y.mom),hl
				ld (attract.gover.y),hl
				ret

;-------------------------------------------------------
attract.gover.move:
; Update ideal game over height.  Use gravity and test for below bottom Y to get a bouncing effect.
				ld hl,(attract.gover.y.mom)
	@apply_gravity:										; Affect momentum with gravity as a force
				ld de,hero.gravity
				add hl,de
				ld (attract.gover.y.mom),hl
	@update_position:			
				ld de,(attract.gover.y)
				add hl,de
				ld (attract.gover.y),hl
	@check_bounce:										; If below floor Y position, reverse momentum and set to bottom Y position
				ld de,attract.gover.bounce.y * &100
				and a
				sbc hl,de
				ret c
				
	@reverse_mom:										; Reduce momentum by 1/4 and turn negative
				ld hl,(attract.gover.y.mom)
				ld e,l
				ld d,h
				sra d
				rr e
				and a
				sbc hl,de
				ex de,hl
				ld hl,0
				and a
				sbc hl,de
				ld (attract.gover.y.mom),hl
	@set_y:
				ld hl,attract.gover.bounce.y * &100
				ld (attract.gover.y),hl
				ret

;-------------------------------------------------------
attract.gover.sprite.updateIX:
; Use updated Y position for sprite Y
				ld a,(attract.gover.y + 1)
				ld ( ix + sprite.yH.os),a
				ret
				
;-------------------------------------------------------
attract.gover.timer.update:
				ld hl,(attract.gover.timer)
				ld a,h
				or l
				or a
				ret z
				dec hl
				ld (attract.gover.timer),hl
				ret

;=======================================================
; 256K APOLOGY MESSAGE

;-------------------------------------------------------
attract.start_logo.256:
; Set attract logo sprite, but flying at half-mast
@main_logo:
				call sprite.ll.append					; Add a sprite
				ld (attract.logo.sprite_base),ix
	@set_routs:											; Set print, update, clear routines
				ld hl,jump.qprintIX
				ld de,attract.logo.update.256
				ld bc,jump.sprite.replace_bgdIX
				call sprite.set_routsIXHLDEBC
	@set_pos:											; Set start position
				ld hl,39 * 2
				ld de,attract.logo.y.start + &50
				call sprite.set_posIXHLDE
	@set_anim:											; Set start animation
				ld a,sprite.anim.logo
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off		; Set visible
				ret

;-------------------------------------------------------
attract.logo.update.256:
; Sprite updater: Set position of logo according to a sine wave
	@get_angle:
				ld a,(attract.logo.sin.os)	
				ld l,a
				ld h,maths.sin_table / &100
				ld a,(hl)					
				inc h						
				ld h,(hl)
				ld l,a
				for 3, add hl,hl			
				
				ld de,(attract.logo.y.start + &50) * &100
				add hl,de
				bit 7,l
				ld ( ix + sprite.yH.os),h
				ld a,h
				ld (hero.y + 1),a
				ret

;-------------------------------------------------------
attract.logo_wobble.update.256:
; Sine update runs slower than normal, because sad.
	@update_sine_wobble:
				ld a,(attract.logo.sin.os)
				add attract.logo.wobble_spd * 0.7
				ld (attract.logo.sin.os),a
				ret			
;-------------------------------------------------------
