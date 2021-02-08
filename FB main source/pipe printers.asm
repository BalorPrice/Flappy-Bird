;-------------------------------------------------------
; PIPE PRINTERS

;-------------------------------------------------------
pipe.y.bottom:	equ map.y.bottom + 8

;-------------------------------------------------------
pipe.print_bottomIX:
; Pipe neck printing
				xor a
				ex af,af'
				jr @+set_printA
				
pipe.print_topIX:
				ld a,1
				ex af,af'
				jr @+set_printA
				
@set_printA:
	@check_death:										; If sprite being killed, don't print anything new
				ld a,( ix + sprite.death.os)
				or a
				ret nz
	@get_print_addr:
				ld l,( ix + sprite.xH.os)
				ld h,( ix + sprite.yH.os)
				ld a,h
				cp pipe.y.bottom
				ret nc
				ret z
				
				srl h
				rr l
				push af									; Store carry for whether printing to odd pixel
						
	@calc_jumps:										; Calc jump into unrolled print loop
				ex af,af'		
				or a		
				jr z,@+bottom		
		@top:		
				xor a		
				ld ( @+set_height1 + 1),a		
				ld ( @+set_height2 + 1),a		
				ld ( @+set_height3 + 1),a		
		
				ld a,h		
				ld h,0		
				jr @+next		
		@bottom:		
	@set_start_height:									; Assumes printing bottom pipe neck
				ld a,h		
				ld ( @+set_height1 + 1),a		
				ld ( @+set_height2 + 1),a		
				ld ( @+set_height3 + 1),a		
						
				ld a,pipe.y.bottom / 2					; Do -(pipe.y.bottom - height) * 2 to get jump offset into unrolled loop
				sub h		
		@next:		
				add a		
				neg 		
				ld c,a		
				ld b,-1		
						
				push hl									; Apply jump offset to each printer type
				ld hl,pipe.print_no_mask.end		
				add hl,bc		
				ld ( @+jump_no_mask + 1),hl		
				ld l,c									; Masked printers have 6 bytes per instance
				ld h,b
				add hl,hl
				add hl,bc
				ld c,l
				ld b,h
				ld hl,pipe.print_mask_left.end
				add hl,bc
				ld ( @+jump_mask_left + 1),hl
				ld hl,pipe.print_mask_right.end
				add hl,bc
				ld ( @+jump_mask_right + 1),hl
				pop hl
				
				ld a,l
				and %01111111
				cp &10
				jr c,@+print_left_clip
				
@print_right_clip:
	@set_width:									; Set width counter for right-clipping
				ld a,&70
				sub l
				and %01111111
				ld e,a
				
				ld bc,&80
				pop af							; Recover smallest X-coord bit from carry
				jp c,@+print_right_align
				jp @+print_left_align
				
@print_left_clip:
	@set_width:
				add 13
				sub &10 
				jr z,@+quit
				jr c,@+quit
				ld e,a
				ld a,13 - 1
				add l
				ld l,a
				
				ld bc,&80
				pop af
				jp c,@+print_right_align.left_clip
				jp @+print_left_align.left_clip
				
@quit:
				pop af
				ret
				
;-------------------------------------------------------
@qprint:
	@set_height1: ld h,0								; Set at beginning of pipe print
	@jump_no_mask: jp 0									; Jump pos for no mask print
	
@qprint_mask_left:
	@set_height2: ld h,0
	@jump_mask_left: jp 0
	
@qprint_mask_right:
	@set_height3: ld h,0
	@jump_mask_right: jp 0

;-------------------------------------------------------
pipe.print_no_mask:
	@full_unroll: equ for &60
				ld (hl),d
				inc h
	next @full_unroll
pipe.print_no_mask.end:
				ld (hl),d
				ret

pipe.print_mask_left:
	@full_unroll: equ for &60
				ld a,(hl)
				and &f0
				or d
				ld (hl),a
				inc h
	next @full_unroll
pipe.print_mask_left.end:
				ld a,(hl)
				and &f0
				or d
				ld (hl),a				
				ret

pipe.print_mask_right:
	@full_unroll:	equ for &60
				ld a,(hl)
				and &0f
				or d
				ld (hl),a
				inc h
	next @full_unroll				
pipe.print_mask_right.end:
				ld a,(hl)
				and &0f
				or d
				ld (hl),a
				ret

;-------------------------------------------------------				
@print_left_align:
				ld d,6							; Data
				call @qprint_mask_left			; Or output call to left/right mask printer
				add hl,bc
				call @qprint_mask_left
				sbc hl,bc
				inc l
				dec e							; E set as counter in normal manner
				ret z
				
				ld d,52		
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,51		
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,50	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,50	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,18	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,17		
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z

				ld d,96	
				call @qprint_mask_right
				add hl,bc
				call @qprint_mask_right
				ret

;-------------------------------------------------------				
@print_right_align:
				; ld d,0								; First byte is blank
				; call @qprint_mask_left
				; add hl,bc
				; call @qprint_mask_left
				; sbc hl,bc
				inc l
				dec e
				ret z
				
				ld d,99	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,67	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,51
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,35
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,33
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z
				
				ld d,33
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				inc l
				dec e		
				ret z

				ld d,22
				call @qprint
				add hl,bc
				call @qprint
				ret

;-------------------------------------------------------				
@print_left_align.left_clip:
				ld d,96	
				call @qprint_mask_right
				add hl,bc
				call @qprint_mask_right
				dec l
				dec e
				ret z
				
				ld d,17		
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z

				ld d,18	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z

				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z

				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z

				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z

				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z

				ld d,34	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z

				ld d,50	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z

				ld d,50	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,51		
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z

				ld d,52		
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,6
				call @qprint_mask_left
				add hl,bc
				call @qprint_mask_left
				ret

;-------------------------------------------------------				
@print_right_align.left_clip:
				ld d,22
				call @qprint
				add hl,bc
				call @qprint
				dec l
				dec e
				ret z
				
				ld d,33
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,33
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,34
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,35
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,51
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,67	
				call @qprint
				add hl,bc
				call @qprint
				sbc hl,bc
				dec l
				dec e
				ret z
				
				ld d,99	
				call @qprint
				add hl,bc
				call @qprint
				ret

;-------------------------------------------------------
