;-------------------------------------------------------
; GRASS ANIMATION

;-------------------------------------------------------

grass.data:												; 1*8 pixel animations.  
					db &33,&22,&22,&33
					db &32,&22,&23,&33
					db &22,&22,&33,&33
					db &22,&23,&33,&32
					db &22,&33,&33,&22
					db &23,&33,&32,&22
					db &33,&33,&22,&22
					db &33,&32,&22,&23
					db &33,&22,&22,&33
					db &32,&22,&23,&33
		
grass.anim:			dw 0								; Anim number 0-7 in 8.8 format

grass.y:			equ map.y.bottom + 12					; y coord for grass - only 3 pixels deep
grass.start.pos1:	equ ((grass.y + 0) * 128) + (224 / 2)	; Addresses to start printing at (right hand side)
grass.start.pos2:	equ ((grass.y + 1) * 128) + (224 / 2)
grass.start.pos3:	equ ((grass.y + 2) * 128) + (224 / 2)

;-------------------------------------------------------
grass.update:
				ld a,(pipe.move.on)
				cp Off
				ret z
				
				ld hl,(grass.anim)
				ld de,(pipe.speed)
				and a
				sbc hl,de
				ld a,h
				and &07
				ld h,a
				ld (grass.anim),hl
				ret
				
;-------------------------------------------------------
grass.print:
; Animate the grass 
				ld a,(grass.anim + 1)
				add a
				add a
				ld c,a
				ld b,0
				ld hl,grass.data
				add hl,bc
				
				ld c,(hl)
				inc hl
				ld b,(hl)
				inc hl
				ld e,(hl)
				inc hl
				ld d,(hl)
				inc hl
				ld iy,grass.start.pos1
				call @+printHLDEBC
				ld c,(hl)
				inc hl
				ld b,(hl)
				inc hl
				ld e,(hl)
				inc hl
				ld d,(hl)
				inc hl
				ld iy,grass.start.pos2
				call @+printHLDEBC
				ld c,(hl)
				inc hl
				ld b,(hl)
				inc hl
				ld e,(hl)
				inc hl
				ld d,(hl)
				inc hl
				ld iy,grass.start.pos3
				call @+printHLDEBC
				
	@clean_edge:										; Clear any corruption if interrupt occurs at end of print
				ld hl,grass.start.pos1 - (96 + 1)
				ld a,dark_grey * &11
				ld (hl),a
				dec l
				ld (hl),a
				inc h
				ld (hl),a
				inc l
				ld (hl),a
				ld bc,-&80
				add hl,bc
				ld (hl),a
				dec l
				ld (hl),a
				ret
				
@printHLDEBC:
				ld ( @+rest_sp + 1),sp
				ld sp,iy
				
		@print_loop: equ for 24
				push de
				push bc
		next @print_loop
				
	@rest_sp:	ld sp,0
				ret

;-------------------------------------------------------