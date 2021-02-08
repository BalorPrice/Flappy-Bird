;-------------------------------------------------------
; PIPES

;-------------------------------------------------------
				include "pipe printers.asm"
				include "pipe cleaners.asm"

;-------------------------------------------------------
pipe.timer:			db 80								; Current time delay before next pipe is spawned
pipe.time:			equ 64								; ! Timer value before next pipe is spawned - Again, should reduce as game progresses
pipe.speed:			dw -&0160							; Speed should get a little faster as game goes on
pipe.x.start:		equ 224 - 1							; Always spawn pipes just to right of printable screen
pipe.y.start:		dw &0000
pipe.gap:			equ &50								; Gap in pipe

pipe.move.on:		db Off								; Set to On when camera is moving - used by grass to animate

;-------------------------------------------------------
pipe.move.stop:
; Set all sprites to speed 0.  This could have been easier with a camera.
	@check_set:
				ld a,(pipe.move.on)						; If movement turned off, stop movement when safe
				cp On
				ret z
				
	@set_off:
				ld a,Off
				ld (pipe.move.on),a
	@check_sprites:										; Test there are sprites to set 
				ld a,(sprite.ll.count)
				or a
				ret z

				ld ix,(sprite.ll.first)
	@loop:
				ld hl,0
				ld de,0
				call sprite.set_speedIXHLDE
				call sprite.ll.goto_nextIX
				jp nz,@-loop				
				ret
				
pipe.move.set_off:
; Set flag to signal to display to stop sprites at next frame
				ld a,Off
				ld (pipe.move.on),a
				ret

;-------------------------------------------------------
pipe.init:
				ld a,On
				ld (pipe.move.on),a
				ret
				
;-------------------------------------------------------
pipe.spawn:
; Create pipes on a timer
	@check_start:
				ld a,(hero.started)
				cp No
				ret z
	@update_timer:
				ld hl,pipe.timer
				dec (hl)
				ret nz
	@make_pipe:
				ld (hl),pipe.time
				
	@get_height:										
				call maths.rand
				ld a,(maths.seed)
				ld b,&60								; Get range of available heights a bit bigger than available
				call maths.modAB
				add &50									; Centre range to usable area
				ld bc,&609b
				call maths.clampABC						; Clamp extremes in a little, to encourage a bit more of the extremes
				ld (pipe.y.start),a
				
@make_bottom_head:										; Head of bottom pipe is the main X
				call @+makeDE
	@set_routs:											; Set print, update, clear routines
				ld hl,jump.qprintIX
				ld bc,jump.sprite.replace_bgdIX
				ld de,pipe.sprite.update
				call sprite.set_routsIXHLDEBC
	@set_pos:											; Set start position
				ld hl,pipe.x.start
				ld de,(pipe.y.start)
				call sprite.set_posIXHLDE
	@set_anim:											; Set start animation
				ld a,sprite.anim.pipe.head
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off
				
				call collider.addIX

@make_bottom_neck:										; Sprite is one line deep, printer extends automatically to bottom of printable page
				call @+makeDE
	@set_routs:											; Set print, update, clear routines
				ld hl,pipe.print_bottomIX
				ld bc,pipe.bottom.replace_bgdIX
				ld de,pipe.sprite.update
				call sprite.set_routsIXHLDEBC
	@set_pos:
				ld hl,(pipe.y.start)
				ld de,14
				add hl,de
				ex de,hl
				ld hl,pipe.x.start
				call sprite.set_posIXHLDE
	@set_anim:
				ld a,sprite.anim.pipe.neck
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off


@make_top_head:
				call @+makeDE
	@set_routs:											; Set print, update, clear routines
				ld hl,jump.qprintIX
				ld bc,jump.sprite.replace_bgdIX
				ld de,pipe.sprite.update
				call sprite.set_routsIXHLDEBC
	@set_pos:											; Set start position
				ld hl,(pipe.y.start)
				ld de,-pipe.gap
				add hl,de
				ex de,hl
				ld hl,pipe.x.start
				call sprite.set_posIXHLDE
	@set_anim:											; Set start animation
				ld a,sprite.anim.pipe.head				; !! Needs real logo
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off		; Set visible
				
				
@make_top_neck:
				call @+makeDE
	@set_routs:											; Set print, update, clear routines
				ld hl,pipe.print_topIX
				ld bc,pipe.top.replace_bgdIX
				ld de,pipe.sprite.update
				call sprite.set_routsIXHLDEBC
	@set_pos:											; Set start position
				ld hl,(pipe.y.start)
				ld de,-&0051
				add hl,de
				ex de,hl
				ld hl,pipe.x.start
				call sprite.set_posIXHLDE
	@set_anim:											; Set start animation
				ld a,sprite.anim.pipe.neck				; !! Needs real logo
				call sprite.set_animAIX
				ld ( ix + sprite.invisible.os),Off		; Set visible
				ret

@makeDE:
				call sprite.ll.append
	@set_speed:
				ld hl,(pipe.speed)
				ld de,0
				call sprite.set_speedIXHLDE
				ret
				
;-------------------------------------------------------
pipe.sprite.update:
; Destroy sprite if off screen
	@check_offscreen:
				ld a,( ix + sprite.xB.os)
				or a
				jr nz,@+kill_sprite
				ld a,( ix + sprite.xH.os)
				cp &20 - 28
				ret nc
				
	@kill_sprite:
				call sprite.killIX
				
				ld a,( ix + sprite.collider.addr.os)	; Delete collider associated if not 0
				ld l,a
				ld a,( ix + sprite.collider.addr.os + 1)
				ld h,a
				or l
				call nz,collider.slot.clearHL
				ret
				
;-------------------------------------------------------
pipe.borders.clear:
; Weird bug if you die on the point a new pipe is generated but enirely invisible
				ld hl,0
				call @+clearHL
				ld hl,&70
				call @+clearHL
				ret
				
@clearHL:
				ld d,h
				ld e,l
				inc de
				ld a,&c0
	@loop:
				ld (hl),dark_grey * &11
				for &10 - 1, ldi
				ld bc,&70 + 1
				add hl,bc
				ex de,hl
				add hl,bc
				ex de,hl
				dec a
				jp nz,@-loop
				ret

;-------------------------------------------------------
