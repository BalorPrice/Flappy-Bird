;-------------------------------------------------------
; COLLIDERS

; Heavily doctored for this game.  There's only one typ of collider - the gap between pipes.  If there's a Y-overlap between collider and hero, then check if hero is entirely within gap.  If so, give points, if not

;-------------------------------------------------------
collider.sprite.os:		equ 0							; Address of main sprite (bottom pipe head) for this collider
collider.ytop.os:		equ 2							; Height of gap
collider.ybottom.os:	equ 3							; bottom of gap
collider.scored.os:		equ 4							; Set to -1 when points awarded for this pipe. Avoid double-scoring.

collider.slot.len:		equ collider.scored.os + 1
collider.slot.max:		equ &10
collider.slot.count:	db 0
collider.slot.data:		ds collider.slot.len * collider.slot.max

collider.hero.x:		equ hero.start.x + 3			; Hitbox for hero is generous so play feels fair
collider.hero.width:	equ 11
collider.hero.y.os:		equ 1
collider.hero.depth:	equ 9

;-------------------------------------------------------
collider.slot.init:
				xor a
				ld (collider.slot.count),a

				ld hl,collider.slot.data
				ld de,collider.slot.data + 1
				ld bc,collider.slot.max * collider.slot.len - 1
				ld (hl),0
				ldir
				ret
				
;-------------------------------------------------------
collider.slot.clearHL:
				ld e,l
				ld d,h
				inc de
				ld bc,collider.slot.len - 1
				ld (hl),0
				ldir
				ret

;-------------------------------------------------------
collider.slot.find_new:
				ld hl,collider.slot.data
				ld de,collider.slot.len
				xor a
				ld b,collider.slot.max
	@loop:
				cp (hl)
				ret z
				add hl,de
				djnz @-loop
	@return_failure:
				cp 1
				ret

;-------------------------------------------------------
collider.addIX:
; Make a new collider for pipe sprite at IX
				call collider.slot.find_new				; Get slot
				ld ( ix + sprite.collider.addr.os),l	; Set sprite slot data
				ld ( ix + sprite.collider.addr.os + 1),h
				ld a,l									; Save into IY
				ld iyl,a
				ld a,h
				ld iyh,a
				ld a,ixl								; Also save sprite base addr in collider slot
				ld ( iy + collider.sprite.os),a
				ld a,ixh
				ld ( iy + collider.sprite.os + 1),a
				
				ld a,( ix + sprite.dest.yH.os)			; !! Use sprite Y for gap position.  Only works as sprite dest just set
				ld ( iy + collider.ybottom.os),a
				sub pipe.gap - 14
				ld ( iy + collider.ytop.os),a
				ret
				
;-------------------------------------------------------
collider.test_all:
; Loop through all colliders and test against hero Y-position.
				ld ix,(hero.sprite_base)
				ld a,( ix + sprite.yH.os)
				add collider.hero.y.os
				ld ( @+hero_y + 1),a
				
				ld iy,collider.slot.data
				ld b,collider.slot.max
	@loop:
				push bc
				
				ld e,( iy + collider.sprite.os)
				ld d,( iy + collider.sprite.os + 1)
				ld a,e
				or d
				or a
				call nz,@+test_collider
				ld bc,collider.slot.len
				add iy,bc
				
				pop bc
				djnz @-loop
				ret

@test_collider:
; First collide X position with hero
				ld ixh,d								; Set IX to pipe sprite
				ld ixl,e
	@test1:												; Is hero left x between pipe left and right boundaries?
				ld a,( ix + sprite.xH.os)
				cp collider.hero.x
				jr nc,@+test2
				add 28									; Add pipe width
				cp collider.hero.x
				jr c,@+test2
				jp @+collided
				
	@test2:												; Is pipe left x between hero left and right boundaries?
				ld a,collider.hero.x
				cp ( ix + sprite.xH.os)
				jr nc,@+end
				add collider.hero.width					; Add hero width
				cp ( ix + sprite.xH.os)
				jr c,@+end
				jp @+collided
	@end:
				xor a
				ret
				
@collided:
	@test_gap:											; Is top of bird below top of gap?
				ld e,hero.die_top
		@hero_y: ld a,0
				cp ( iy + collider.ytop.os)
				jr c,@+kill_bird
				ld e,hero.die_bottom
				add collider.hero.depth					; Is bottom of bird above top of gap?  Add bird_depth
				cp ( iy + collider.ybottom.os)
				jr c,@+award_points
	@kill_bird:
				ld a,e
				ld (hero.ok),a
				
				ld c,sfx.hit_pipe
				call sfx.setC.out
				ret
				
@award_points:
; If hero is through the opening then award a points
	@test_x_pos:
				ld a,( ix + sprite.xH.os)
				cp collider.hero.x
				jp nc,@+end
	@check_scored:
				ld a,( iy + collider.scored.os)
				or a
				jr nz,@+next
		@add_point:
				call hud.score.inc						; Add score
		@play_ping:
				ld c,sfx.score_point					; Play award ping noise
				call sfx.setC.out
		@next:
				ld ( iy + collider.scored.os),-1
	@end:
				xor a									; Return Z for game state logic
				ret
				
;-------------------------------------------------------
