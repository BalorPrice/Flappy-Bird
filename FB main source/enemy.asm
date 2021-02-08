;-------------------------------------------------------
; ENEMIES

enemy.mod:
;-------------------------------------------------------
				include "enemies/butterfly.asm"
				include "enemies/beetle.asm"
				include "enemies/walker.asm"
				include "enemies/rlaunch.asm"
				include "enemies/pod.asm"
				include "enemies/gmech.asm"
				include "enemies/xeno.asm"
				include "enemies/turret.asm"
				include "enemies/rotary_gun.asm"
				include "enemies/omech.asm"
				include "enemies/dob.asm"

;-------------------------------------------------------
enemy.qprint.on:	db Off								; Main switch for quick print routines active

;-------------------------------------------------------
enemy.clearIX:
; Clear current position of enemy
	@check_active:
				ld a,(enemy.qprint.on)
				cp Off
				ret z

	@check_x_printable:									; Check not off the screen.
				ld a,( ix + sprite.xB2.os)
				or a
				ret nz
				
	@check_y_printable:									; If sprite coord above screen, try to clip it vertically
				ld a,( ix + sprite.yB2.os)
				cp -1
				jp z,sprite.clearIX
				
				ld a,( ix + sprite.xH2.os)
				add ( ix + sprite.x_offset2.os)
				ld e,a
				ld a,( ix + sprite.yH2.os)
				add ( ix + sprite.y_offset2.os)
				
			if defined (DEBUG)
				ld bc,&01a0
				call maths.clampABC
			endif 
			
				ld d,a
				srl d
				rr e

				ld a,( ix + sprite.frame2.width.os)
				or a									; !! This should be tested in sprite.replace_bgd
				ret z
				ld b,( ix + sprite.frame2.depth.os)
				call gfx.clear_grab.nohead				; Use the basic clear routine for now!
				ret

;-------------------------------------------------------
enemy.qprintIX:
; Quick test to print with quick print routine if available
	@check_active:
				ld a,(enemy.qprint.on)
				cp Off
				ret z
				
	@check_x_printable:									; Check not off the screen.
				ld a,( ix + sprite.xB.os)
				or a
				ret nz
				
	@check_y_printable:									; If sprite coord above screen, try to clip it vertically
				ld a,( ix + sprite.yB.os)
				cp -1
				jp z,sprite.print_frameIX
				
@find_frame_data:										; HL = sprite.frames+(8*A)
				ld l,( ix + sprite.frame.os)
				ld h,0
				for 3,add hl,hl
				ex de,hl
				ld iy,sprite.frames
				add iy,de
				

@get_dest_coords:
				ld a,( ix + sprite.xH.os)
				add ( ix + sprite.x_offset.os)
				ld e,a
				ld a,( ix + sprite.yH.os)
				add ( ix + sprite.y_offset.os)

			if defined (DEBUG)
				ld bc,&01a0
				call maths.clampABC
			endif
				ld d,a
				
	@test_right_clip:
				ld a,e									; If x > map.x.right then totally off screen, quit printing
				cp map.x.right
				ret nc
				add ( iy + sprite.frames.width.os)		; If x + width > map.x.right then clip right hand side
				jp c,sprite.printIXIYDE
				add ( iy + sprite.frames.width.os)
				jp c,sprite.printIXIYDE
				cp map.x.right
				jp nc,sprite.printIXIYDE
				
	@test_left_clip:
				ld a,e
				cp map.x.left
				jp c,sprite.printIXIYDE
				
	@no_clip:	
				push ix
				
				ld h,enemy.comp.jump_tab / &100
				srl d									; Get screen address
				rr e
				jr nc,@+skip
				ld h,(enemy.comp.jump_tab / &100) + 3
	@skip:
				ld l,( ix + sprite.frame.os)

				ld c,(hl)								; Get page
				inc h
				ld a,(hl)								; Get routine address
				ld ixl,a
				inc h
				ld a,(hl)
				ld ixh,a
				
				ld a,c
				ex de,hl								; Leave dest address in HL
				call jump.gfx_printAIX
				
				pop ix
				ret

;-------------------------------------------------------
enemy.qclear1224IX:
; Sprite clearing optimised for speed for just this sized sprite.  
; Used for xenomorphs and rotary guns as these are sprite-heavy sections of the game
				ld a,( ix + sprite.xH2.os)
				add ( ix + sprite.x_offset2.os)
				ld l,a
				ld a,( ix + sprite.yH2.os)
				add ( ix + sprite.y_offset2.os)
				ld h,a
				
				srl h
				rr l
				
				push hl
				
				ld a,l
				add 22 / 2
				ld l,a
				
				ld de,0
				
				ld ( @+rest_sp + 1),sp
				
	@y_loop1: equ for 12
				ld sp,hl
				for 4,push de
				inc h
	next @y_loop1
	
				ld bc,-&80
				add hl,bc
				
	@y_loop2: equ for 12
				ld sp,hl
				for 4,push de
				dec h
	next @y_loop2
				
	@rest_sp:	ld sp,0
	
				pop hl
				
				xor a
	@slalom1: equ for 6
				ld (hl),a
				inc l
				ld (hl),a
				inc l
				ld (hl),a
				inc h
				ld (hl),a
				dec l
				ld (hl),a
				dec l
				ld (hl),a
				inc h
	next @slalom1

				ld bc,-&80
				add hl,bc

	@slalom2: equ for 6
				ld (hl),a
				inc l
				ld (hl),a
				inc l
				ld (hl),a
				dec h
				ld (hl),a
				dec l
				ld (hl),a
				dec l
				ld (hl),a
				dec h
	next @slalom2
				ret
				
;-------------------------------------------------------
