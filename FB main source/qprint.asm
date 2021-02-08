;-------------------------------------------------------
; QPRINT

;-------------------------------------------------------
qprint.printIX:
; Quick test to print with quick print routine if available				
@find_frame_data:										; HL = sprite.frames+(8*A)
				ld l,( ix + sprite.frame.os)
				ld h,0
				for 3,add hl,hl
				ex de,hl
				ld iy,sprite.frames
				add iy,de
				
@get_dest_coords:
				ld e,( ix + sprite.xH.os)
				ld d,( ix + sprite.yH.os)
				
				push ix
				
				ld h,comp.jump_tab / &100
				srl d									; Get screen address
				rr e
				jr nc,@+skip
				ld h,(comp.jump_tab / &100) + 3
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
