;-------------------------------------------------------
; HERO MOVEMENT

;-------------------------------------------------------
hero.sprite_base: 			dw 0						; Address of hero sprite
hero.start.x:				equ &0060					; Start coords in 16.0 format
hero.start.y:				equ &0050                   
hero.flap.mom.y:			equ -&0400					; Specific momentum when flap is tapped
hero.gravity:				equ &003e					; 8.8 value for gravity*mass force of bird.  Tweaked by hand til it worked
														
hero.y:						dw 0						; 50hz update of actual position, in 8.8 format
hero.y.mom:					dw 0						; Momentum - down is positive
hero.death_timer:			db 0						; Timer for final fall
hero.death_time:			equ 50						; Time to wait performing final fall
														
hero.started:				db No						; If No, sprite not in player's control yet
hero.ok:					db 0						; State of hero
hero.die_top:				equ -1                      
hero.die_bottom:			equ -2                      
														
map.y.bottom:				equ &a2						; Actual bottom Y coord hero will die at

hero.tap_flap.sprite_base:	dw 0						; Address of tap-to-flap sign sprite
hero.tap_flap.x:			dw 0						; 50 hz update of real position in 8.8 format
hero.tap_flap.x.mom:		dw 0						; Sideways momentum of sign
hero.tap_flap.start.x:		equ 223
hero.tap_flap.target.x:		equ hero.start.x + 34
hero.tap_flap.timer:		db 0						; Current delay before help sign
hero.tap_flap.delay:		equ 80						; Time before help sign appears

;=======================================================
hero.init:
; Set sprite for start of new life on road level
@set_sprite_obj:
				call sprite.ll.append					; Create new sprite slot
				ld (hero.sprite_base),ix
	@set_routs:											; Set print, update, clear routines
				ld hl,jump.qprintIX
				ld de,hero.sprite.updateIX
				ld bc,jump.sprite.replace_bgdIX
				call sprite.set_routsIXHLDEBC
	@set_pos:											; Set start position
				ld hl,hero.start.x
				ld de,hero.start.y						; in 16.0 format (ie all pixels)
				call sprite.set_posIXHLDE
				ld hl,hero.start.y * &100				; Get y pos in 8.8 format (for momentum calculations)
				ld (hero.y),hl
	@set_anim:											; Set start animation
				ld a,sprite.anim.hero.flap
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off		; Set visible
				
@reset_momentum:
				ld hl,0
				ld (hero.y.mom),hl
				
				ld a,Yes
				ld (hero.ok),a
				ld a,No									; Set to get-ready mode, sprite wobbles instead of applying gravity
				ld (hero.started),a
				ret

;-------------------------------------------------------
hero.move:
; Update ideal hero pos
; This updates at 50hz, sprite takes overall position from it
	@check_mode:
				ld a,(keys.processed)
				bit Fire,a
				jr nz,@+run
				ld a,(hero.started)
				cp No
				ret z

	@run:
				ld hl,(hero.y.mom)
	@apply_flap:										; If new flap found, change momentum to specific value.  Yep, 
				ld a,(keys.processed)
				bit Fire,a
				jr z,@+apply_gravity
				
				ld a,Yes								; Set as playing now.
				ld (hero.started),a
				
				ld hl,hero.flap.mom.y
				ld (hero.y.mom),hl
				
				push hl
				ld hl,0
				ld c,sfx.flap							; Play flap noise
				ld a,(music.on)							; Only play if music not playing
				or a
				call nz,sfx.setC.out
				pop hl
				
	@apply_gravity:										; Affect momentum with gravity as a force
				ld de,hero.gravity
				add hl,de
				ld (hero.y.mom),hl
				ld a,h
	@update_position:			
				ld de,(hero.y)
				add hl,de
		@clamp_top:										; If -ve momentum and hero.y carried to -ve, then clampe to top of screen
				jr c,@+store
				bit 7,a
				jr z,@+store
				ld hl,0
				ld (hero.y.mom),hl						; Reset momentum immediately
				jr @+store
		@store:
				ld (hero.y),hl
				ret
				
;-------------------------------------------------------
hero.sprite.updateIX:
; Update routine for hero sprite.
	@check_mode:
				ld a,(hero.started)
				cp No
				jr z,@+auto_height
	@get_y:												; Use updated Y position for sprite Y
				ld a,(hero.y + 1)
				ld ( ix + sprite.yH.os),a
	@clamp_y:
				ld a,( ix + sprite.yB.os)
				or a
				jr nz,@+clamp_top
				ld a,( ix + sprite.yH.os)
				cp map.y.bottom
				jr nc,@+clamp_bottom
				ret

	@clamp_top:											; Clamping to top does not kill sprite
				ld ( ix + sprite.yH.os),0
				ld hl,0									; But momentum is also reset
				ld (hero.y.mom),hl
				ld (hero.y),hl
				ret

	@clamp_bottom:										; Clamping to bottom results in death
				ld ( ix + sprite.yH.os),map.y.bottom
				ld hl,0
				ld (hero.y.mom),hl
				ld hl,&100 * map.y.bottom
				ld (hero.y),hl
				
				ld a,hero.die_bottom
				ld (hero.ok),a
				
				ld c,sfx.hit_ground
				call sfx.setC.out
				
				ld hl,0									; Stop calling update routine
				call sprite.set_update_routIXHL
				ret
				
@auto_height:
; If player hasn't pressed space yet, keep hovering.  This will stop immediate death from not being ready.
	@get_angle:
				ld a,(attract.logo.sin.os)				; Sine offset updated in game.attract.run at 50hz
				ld l,a
				ld h,maths.sin_table / &100
				ld a,(hl)								; Get Sine value in 8.8 format
				inc h									; Sine table stored vertically, aligned to MSB address boundary
				ld h,(hl)
				ld l,a
				for 3, add hl,hl						; Multiply movement to 8 pixels up/down for wobble
				
				ld de,hero.start.y * &100				; Add to central logo position
				add hl,de
				bit 7,l
				ld ( ix + sprite.yH.os),h
				ret

;-------------------------------------------------------
hero.kill:
; Collision detected, perform death motion and set timer
	@set_anim:											; No death spiral, just stop flapping
				ld ix,(hero.sprite_base)
				ld a,sprite.anim.hero.hit				; Same as coast anim but with a frame or two of flashed white
				call sprite.set_animAIX
	@set_mom:											; Set hero y momentum for final fall
				ld hl,hero.flap.mom.y * 1.2
				ld a,(hero.ok)
				cp hero.die_bottom
				jr z,@+skip
				ld hl,hero.flap.mom.y * 0.4
		@skip:
				ld (hero.y.mom),hl
	@set_timer:
				ld a,30
				ld (hero.death_timer),a
				
				ret

;-------------------------------------------------------
hero.move.dead:
; Update ideal hero pos for death fall.
				ld hl,(hero.y.mom)
	@apply_gravity:
				ld de,hero.gravity
				add hl,de
				ld (hero.y.mom),hl
				ld a,h
	@update_position:			
				ld de,(hero.y)
				add hl,de
				ld (hero.y),hl
	@update_timer:										; Count down timer, return Z if completed.
				ld hl,hero.death_timer
				dec (hl)
				ret

;-------------------------------------------------------
hero.floored:
; Change hero animation for staying on floor
	@set_anim:
				ld ix,(hero.sprite_base)
				ld a,sprite.anim.hero.coast
				call sprite.set_animAIX
				ret

;=======================================================
; TAP-TO-FLAP SIGN

;-------------------------------------------------------
hero.tap_flap.init:
				ld a,hero.tap_flap.delay
				ld (hero.tap_flap.timer),a
				ret

;-------------------------------------------------------
hero.tap_flap.start:
; Init tap to flap sign
	@check_game_start:									; If game already started when creating, skip entirely
				ld a,(hero.started)
				cp Yes
				ret z
@set_sprite_obj:
				call sprite.ll.append					; Create new sprite slot
				ld (hero.tap_flap.sprite_base),ix
	@set_routs:											; Set print, update, clear routines
				ld hl,jump.qprintIX
				ld de,hero.tap_flap.sprite.updateIX
				ld bc,jump.sprite.replace_bgdIX
				call sprite.set_routsIXHLDEBC
	@set_pos:											; Set start position
				ld hl,hero.tap_flap.start.x
				ld de,hero.start.y						; in 16.0 format (ie all pixels)
				call sprite.set_posIXHLDE
				ld hl,hero.tap_flap.start.x * &100
				ld (hero.tap_flap.x),hl
	@set_anim:											; Set start animation
				ld a,sprite.anim.tap_flap
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off		; Set visible
				
@reset_momentum:
				ld hl,-&0100
				ld (hero.tap_flap.x.mom),hl
				ret
				
;-------------------------------------------------------
hero.tap_flap.update:
; 50 hz position updater
	@update_timer:
				ld a,(hero.tap_flap.timer)
				or a
				jr z,@+update_sign
				dec a
				ld (hero.tap_flap.timer),a
				cp 1
				call z,hero.tap_flap.start
				ret
				
	@update_sign:
				ld a,(hero.started)
				cp Yes
				jr z,@+move_right
@bounce_left:
	@update_momentum:
				ld hl,(hero.tap_flap.x.mom)
				ld de,-hero.gravity * 1.8
				add hl,de
				ld (hero.tap_flap.x.mom),hl
				ld de,(hero.tap_flap.x)
				add hl,de
				ld (hero.tap_flap.x),hl
	@bounce:
				ld a,h
				cp hero.tap_flap.target.x
				ret nc
	@reverse_mom:										; Reduce momentum by 1/2 and turn negative
				ld hl,(hero.tap_flap.x.mom)
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
				ld (hero.tap_flap.x.mom),hl
				ld h,hero.tap_flap.target.x
				ld (hero.tap_flap.x),hl
				ret

@move_right:
	@update_momentum:
				ld hl,(hero.tap_flap.x.mom)
				ld de,hero.gravity * 2
				add hl,de
				ld (hero.tap_flap.x.mom),hl
				ld de,(hero.tap_flap.x)
				add hl,de
				ld (hero.tap_flap.x),hl
				ret	

;-------------------------------------------------------
hero.tap_flap.sprite.updateIX:
; Sprite update rout
				ld a,(hero.tap_flap.x + 1)
				ld ( ix + sprite.xH.os),a
	@check_death:
				cp 224
				call nc,sprite.killIX
				ret

;-------------------------------------------------------
