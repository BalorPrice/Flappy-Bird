;-------------------------------------------------------
; PIPE CLEANER ROUT


;-------------------------------------------------------
pipe.cleaner.install:
; Install pipe.cleaner mod beneath screen3
				; di
				; halt
	@paging:
				in a,(LMPR)
				ld ( @+rest_hi + 1),a
				ld a,ScreenPage3 + ROMOut
				out (LMPR),a
	@move:	
				ld hl,pipe.cleaner.src
				ld de,pipe.cleaner.start - &8000
				ld bc,pipe.cleaner.len
				ldir
	@pagine:	
	@rest_hi:	ld a,0
				out (LMPR),a
				ret
				
;=======================================================
pipe.cleaner.src:
				org int.end + &8000						; This code to sit underneath screen3 and execute in high pages
				
pipe.cleaner.start:
;-------------------------------------------------------
pipe.replace_bgdBCHL:
; Clear pipe of depth B, with C (in bytes), at HL back to background
	@get_jump_addr:
				ld a,b									; Multiply by 4 for the length of the unrolled loop
				; add a
				and %11111110							; Equivalent of divide by 2 (only clearing y-parity coords) then multiply by 2
				neg
				ld e,a
				ld d,-1
				sla e
				rl d
				ld iy,pipe.replace.end					; Negate and add to end of routine to get jump address
				add iy,de
				ld ( @+jump + 1),iy
	@get_source:
				srl h									; Convert from pixels to screen address
				rr l
				ld e,l
				ld a,h
				ld ( @+y_pos + 1),a
				
				; di
				; halt
				ld iyl,c								; Keep iyl as loop counter (assume any clipping already done)
				ld bc,&80
	@unroll_x_loop: equ for 13
				call pipe.replace_column				; Print one parity of y-coords (even or odd Y coords)
				add hl,bc
				ld e,l
				call pipe.replace_column				; Print other parity
				sbc hl,bc
				inc l									; Next column
				ld e,l
				dec iyl
				ret z
	next @unroll_x_loop
				call pipe.replace_column
				add hl,bc
				call pipe.replace_column
				ret

;-------------------------------------------------------
pipe.replace_column:
; Replace single byte column of sprite from screen3.  IY set as jump position
		@y_pos:	ld d,0									; Set y-coord.  Bit 7 of L set outside routine
				ld h,d
				set 7,h
		@jump:	jp 0

	@unroll_y_loop: equ for &60
				ld a,(hl)								; Unrolled loop 4 bytes, 22ts.  5.5ts per pixel ish
				ld (de),a
				inc h
				inc d
	next @unroll_y_loop
pipe.replace.end:
				ld a,(hl)
				ld (de),a
				ret
				
;-------------------------------------------------------
pipe.cleaner.end:
pipe.cleaner.len:	equ pipe.cleaner.end - pipe.cleaner.start

;=======================================================
				org pipe.cleaner.src + pipe.cleaner.len
