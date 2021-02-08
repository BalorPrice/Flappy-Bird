;-------------------------------------------------------
; HEADS-UP DISPLAY

;-------------------------------------------------------
hud.score:					db &00,&00					; Current score, 3 digits with one nibble each.  Top nibble of byte 0 not used.
hud.score.best:				db &00,&00

hud.digit.sprite_base.0:	dw 0						; Sprite slot base address for each digit 
hud.digit.sprite_base.1:	dw 0
hud.digit.sprite_base.2:	dw 0

hud.digit.x.start:			equ &0071

;=======================================================

;-------------------------------------------------------
hud.init:
; Initialise HUD elements at the beginning of a life/level.  Don't print til hud.print_first is invoked.
				call hud.score.reset				
				ld hl,hud.digit.sprite_base.0
				ld de,hud.digit.x.start
				ld b,3
	@loop:
				push bc
				push de
				push hl
				call @+make_digit
				pop hl
				ld e,ixl
				ld d,ixh
				ld (hl),e
				inc hl
				ld (hl),d
				inc hl
				
				pop de
				ex de,hl
				ld bc,6
				add hl,bc
				ex de,hl
				
				pop bc
				djnz @-loop
				
				ld ( ix + sprite.invisible.os),Off		; Always set the final digit to visible
				ret

@make_digit:
; Create score digit as a sprite
				push de
				call sprite.ll.append
	@set_routs:									
				ld hl,jump.qprintIX
				ld de,0
				ld bc,jump.sprite.replace_bgdIX
				call sprite.set_routsIXHLDEBC
	@set_pos:			
				pop hl
				ld de,&08
				call sprite.set_posIXHLDE
				
	@set_anim:									
				ld a,sprite.anim.0
				call sprite.set_animAIX
				ret
				
;-------------------------------------------------------
hud.score.reset:
				ld hl,hud.score
				ld (hl),0
				inc hl
				ld (hl),0
				ret	

;-------------------------------------------------------
hud.score.inc:
; Increase score by one.  Bit hacky, not sure I mind.
	@update_logical_score:
				and a
				ld a,(hud.score + 1)					; Score held in big endian to match decimal
				inc a
				daa
				ld (hud.score + 1),a
				jr nc,@+update_sprites
				ld hl,hud.score
				inc (hl)								; Flips to 0 if more than 999 scored
	
	@update_sprites:
				ld hl,hud.digit.sprite_base.2 + 1
				ld bc,hud.score + 1

		@get_sprite_slot:
				ld d,(hl)
				ld ixh,d
				dec hl
				ld e,(hl)
				ld ixl,e
				dec hl
		@get_digit:
				ld a,(bc)								; Get bottom nibble for 1st digit
				and &0f
				jr z,@+skip
				ld ( ix + sprite.invisible.os),Off		; Make digit visible if not 0
			@skip:
				add sprite.anim.0						; Get animation for this digit
				push bc
				push hl
				call sprite.set_animAIX					; Set digit animation
				pop hl
				pop bc
				
		@get_sprite_slot:								; Repeat for other nibble
				ld d,(hl)
				ld ixh,d
				dec hl
				ld e,(hl)
				ld ixl,e
				dec hl
		@get_digit:
				ld a,(bc)								; Get bottom nibble for 1st digit
				for 4,srl a
				and &0f
				jr z,@+skip
				ld ( ix + sprite.invisible.os),Off		; Set digit visible if not 0
			@skip:
				add sprite.anim.0						; Get animation for this digit
				push bc
				push hl
				call sprite.set_animAIX					; Set digit animation
				pop hl
				pop bc
				
				dec bc
				
		@get_sprite_slot:
				ld d,(hl)
				ld ixh,d
				dec hl
				ld e,(hl)
				ld ixl,e
		@get_digit:
				ld a,(bc)								; Get bottom nibble for 1st digit
				and &0f
				jr z,@+skip
				ld ( ix + sprite.invisible.os),Off		; Make digit visible if not 0
			@skip:
				add sprite.anim.0						; Get animation for this digit
				call sprite.set_animAIX					; Set digit animation
				
				call hud.score.centre
				ret

;-------------------------------------------------------
hud.score.centre:
; Recentre numbers positions based on width of score
				call @+calc_overall_width
	@calc_start_pos:									; Start position = &80 - (Total / 2)
				srl a
				neg
				add &80
				
				ld e,a									; E keeps tally of X pos
				ld d,0									; Keep track of leading zeroes for zero length
				ld h,d									; H = xB value for sprite
				
	@set_dig_1:											; Set X pos for digit
				ld ix,(hud.digit.sprite_base.0)
				ld l,e
				call sprite.set_xposIXHL
		@add_dig_width:									; Calc position of next digit
				ld a,(hud.score)
				and &0f
				call @+add_widthADE		
	@set_dig_2:											; Repeat for next two digits
				ld ix,(hud.digit.sprite_base.1)
				ld l,e
				call sprite.set_xposIXHL
				
				ld a,(hud.score + 1)
				for 4,srl a
				call @+add_widthADE		
	@set_dig_3:			
				ld ix,(hud.digit.sprite_base.2)
				ld l,e
				call sprite.set_xposIXHL
				ret


@calc_overall_width:
; Return width of printable characters
				ld d,0
				ld e,0
				ld a,(hud.score)
				and &0f
				call @+add_widthADE
				ld a,(hud.score + 1)
				for 4,srl a
				call @+add_widthADE
				ld a,(hud.score + 1)
				and &0f
				call @+add_widthADE
	@check_width:										; If score is zero, use default (width of one zero digit)
				ld a,e
				or a
				ret nz
				ld a,6
				ret

@add_widthADE:
; Add width of digit A to tally E.  If D=0, assume leading zeroes will be invisible and skip.
	@check_leading_zeroes:
				bit 7,d									; If previous digit is non-zero, count all numbers
				jr nz,@+skip
				or a									; Otherwise, check if this is a leading zero, quit if so
				ret z
				dec d
		@skip:
				cp 1									; 1s are narrower than other digits
				jr z,@+width_1
	@width_norm:
				ld a,e
				add 6									; These are one pixel too small so digits overlap
				ld e,a
				ret
	@width_1:
				ld a,e
				add 4
				ld e,a
				ret
				
;-------------------------------------------------------
				