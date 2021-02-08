;-------------------------------------------------------
; JUMP ROUTINES

; Each routine that needs paging into high pages has its own jump routine.  On start-up these routines are copied below each screen.


;-------------------------------------------------------
jump.prep:
; Move jump routines under both screens (and the backup screen)
				ld b,2
				ld a,ScreenPage1 + ROMOut
	@loop:
				out (LMPR),a
				push bc
				ex af,af'
				
	@move_routines:										; Move module beneath this screen
				ld hl,jump.src
				ld de,int.end
				ld bc,jump.len
				ldir
				 
				ex af,af'
				for 2,inc a
				pop bc
				djnz @-loop		
				
	@end:												; Restore original working screen
				ld a,ScreenPage1 + ROMOut
				out (LMPR),a
				ret
				
;-------------------------------------------------------

jump.src:
;=======================================================
				org int.end
jump.start:

				ds &40
jump.stack:

			if defined (DEBUG)
				nop
			endif

;-------------------------------------------------------
jump.prep_scroll:
; Prepare scrolled sprite data.
	@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				ld a,GfxPage1
				out (HMPR),a
				
				ld hl,gfx.scroll_data.start
				ld de,gfx.scroll_data.scrolled
				ld bc,gfx.scroll_data.len
	@copyHLDEBC:
				push de
				push bc
				ldir
	@scroll:
				pop bc
				pop hl
				call jump.scrollHLBC
				
	@paging:
				ld a,MainPage
				out (HMPR),a
	
				ld hl,font.data.scrolled
				ld bc,font.data.len
				call jump.scrollHLBC

	@rest_sp:	ld sp,0
				ret
				
;-------------------------------------------------------
jump.scrollHLBC:
; Scroll grab data without header at HL right by one nibble.  Length BC bytes.  First nibble is padded with 0, last nibble is lost.
				ld e,0
	@loop:
				ld a,(hl)
				srl e
				rra
				rr e
				rra
				rr e
				rra
				rr e
				rra
				rr e
				for 4,rr e
				ld (hl),a
				inc hl
				dec bc
				ld a,b
				or c
				jr nz,@-loop
				ret

;-------------------------------------------------------
jump.copy_screen:
; Save current visable screen to backup screen
	@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				in a,(VMPR)
				and %000111111
				out (HMPR),a	
	@setup:
				ld hl,&8000
				ld de,0
				ld bc,&c0 * 4
	@loop:					
				push bc
				for 32,ldi
				pop bc
				dec c
				jr nz,@-loop
				dec b
				jr nz,@-loop
				
	@paging:
				ld a,MainPage
				out (HMPR),a
	@rest_sp:	ld sp,0
				ret
				
;-------------------------------------------------------
jump.save_screen:
; Save current screen to screen3 for quick replacing underneath sprites
	@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				ld a,ScreenPage3
				out (HMPR),a	
	@setup:
				ld hl,0
				ld de,&8000
				ld bc,&c0 * 4							; Set up loop for each line of screen * 4 loops per line
	@loop:												; Some unrolling done here for speed.
				push bc
				for 32,ldi
				pop bc
				dec c
				jr nz,@-loop
				dec b
				jr nz,@-loop
				
	@paging:
				ld a,MainPage
				out (HMPR),a
	@rest_sp:	ld sp,0
				ret

;-------------------------------------------------------
jump.qprintIX:
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
				
	@test_left_clip:									; If X byte < &10 then set to print clip left routine
				ld a,e
				and %01111111
				cp &10
				jr nc,@+skip
				set 7,l
		@skip:

				ld c,(hl)								; Get page
				inc h
				ld a,(hl)								; Get routine address
				ld ixl,a
				inc h
				ld a,(hl)
				ld ixh,a
				
				ld a,c
				ex de,hl								; Leave dest address in HL

	@gfx_printAIX:
				push hl
				ld ( @+stack + 1),sp
				ld sp,jump.stack
				
				out (HMPR),a
				ld ( @+jump + 1),ix
		@jump:	call 0

				ld a,MainPage
				out (HMPR),a
		@stack:	ld sp,0
				pop hl
				
				pop ix
				ret

;-------------------------------------------------------				
pipe.bottom.replace_bgdIX:
; Replace pipe neck bottom.  Sprite updater
				xor a
				ex af,af'
				jr @+check_full_clearA

pipe.top.replace_bgdIX:
; Replace pipe neck top. Sprite updater
				ld a,1
				ex af,af'
				jr @+check_full_clearA

@check_full_clearA:										; If game playing, use quick clear, otherwise do full one
; Replace background for sprite at IX.
; Takes data from screen3 to reprint for speed.
				ld a,( ix + sprite.xH2.os)
				sub ( ix + sprite.xH.os)
				ret z
				ld c,a									; Keep amount of pixels to clear for later

@find_frame_data:
				ld h,( ix + sprite.yH.os)				; Get start coords 
				ld a,( ix + sprite.xH.os)
				add 28 - 8
				ld l,a
				srl c									; Convert width to bytes to clear
				for 4,inc c
				
				ex af,af'
				or a
				jr z,@+set_bottom
				
	@set_top:											; Correct start Y coord and set depth to print
				ld b,h
				inc b
				ld h,0
				jr @+paging
	@set_bottom:										; Just set depth to print
				ld a,pipe.y.bottom + 2
				sub h
				ret c
				ret z
				ld b,a
				
	@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				ld a,ScreenPage3
				out (HMPR),a
				
				call pipe.replace_bgdBCHL		
				
	@paging:
				ld a,MainPage
				out (HMPR),a
	@rest_sp:	ld sp,0
				ret

;-------------------------------------------------------
jump.print_frameADE:
; Print frame A to (D,E), not attached to any sprite
	@find_frame_data:									; Get frame data
				ld l,a
				ld h,0
				for 3,add hl,hl
				ex de,hl
				ld ix,sprite.frames
				add ix,de
				ex de,hl
				
				ld l,( ix + sprite.frames.src.os)
				ld h,( ix + sprite.frames.src.os + 1)

	@test_pixel_scroll:									; If printing to odd X-coord, offset to correct data
				bit 0,e
				jr z,@+skip
				ld bc,gfx.scroll_data.len
				add hl,bc
		@skip:
				ld c,( ix + sprite.frames.width.os)
				ld b,( ix + sprite.frames.depth.os)

				ld a,c
				add a
				add e
				jr c,@+print_clipped
				cp 224 - 1
				jr c,@+print_all
				
@print_clipped:											; Set values for moving down a line, amount to print and amount to skip in graphic
				ld a,224
				sub e
				srl a
				ld ( @+print_val + 1),a
				neg
				add c
				ld ( @+skip_val + 1),a
				jr @+setup_depth

	@print_all:
				xor a
				ld ( @+skip_val + 1),a
				ld a,c
				ld ( @+print_val + 1),a
				
@setup_depth:
				srl d
				rr e
@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				
				in a,(HMPR)
				ld ( @+rest_lo + 1),a
				ld a,( ix + sprite.frames.page.os)
				out (HMPR),a
				
				ld a,b
@y_loop:		
				push de
		@print_val: ld bc,0
				ldir
		@skip_val:	ld bc,0
				add hl,bc
				
				ld bc,&80
				pop de
				ex de,hl
				add hl,bc
				ex de,hl

				dec a
				jr nz,@-y_loop
				
	@rest_lo:	ld a,0
				out (HMPR),a
	@rest_sp:	ld sp,0
				ret

;-------------------------------------------------------
jump.print_frame.maskADE:
; Print frame A to (D,E), masked to 0.  Not attached to any sprite
	@find_frame_data:									; Get frame data
				ld l,a
				ld h,0
				for 3,add hl,hl
				ex de,hl
				ld ix,sprite.frames
				add ix,de
				ex de,hl
				
				ld l,( ix + sprite.frames.src.os)
				ld h,( ix + sprite.frames.src.os + 1)

	@test_pixel_scroll:									; If printing to odd X-coord, offset to correct data
				bit 0,e
				jr z,@+skip
				ld bc,gfx.scroll_data.len
				add hl,bc
		@skip:
				ld c,( ix + sprite.frames.width.os)
				ld b,( ix + sprite.frames.depth.os)
				ld a,( ix + sprite.frames.page.os)
				jp @+paging
				
;-------------------------------------------------------
jump.sprite.print_maskedIX:
; Print frame in sprite object IX.  Assume no clipping.		
@find_frame_data:
	@get_dest_coords:
				ld e,( ix + sprite.xH.os)
				ld d,( ix + sprite.yH.os)
	@get_src_data:
				ld l,( ix + sprite.frame.src.os)
				ld h,( ix + sprite.frame.src.os + 1)
	@test_pixel_scroll:									; If printing to odd X-coord, offset to correct data
				bit 0,e
				jr z,@+get_width_depth
				ld bc,gfx.scroll_data.len
				add hl,bc
	@get_width_depth:
				ld c,( ix + sprite.frame.width.os)
				ld b,( ix + sprite.frame.depth.os)
				ld a,( ix + sprite.frame.page.os)
				; jp @+paging

;-------------------------------------------------------
@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				ex af,af'
				in a,(HMPR)
				ld ( @+rest_lo + 1),a
				ex af,af'
				out (HMPR),a
				
@get_offset:											; Calculate 128-width for easy next_line calculation
				ld a,&80
				sub c
				ld ( @+offset + 1),a
				
@find_scr_addr:
				srl d
				rr e
@print:
	@y_loop:
				push bc
		@x_loop:
				ld a,(de)
				ld iyl,a
				
				ld a,(hl)
				and &f0
				jr z,@+skip
				ld a,iyl
				and &0f
				ld iyl,a
			@skip:
				ld a,(hl)
				and &0f
				jr z,@+skip
				ld a,iyl
				and &f0
				ld iyl,a
			@skip:
				ld a,(hl)
				or iyl
				ld (de),a

				inc de
				inc hl
				
				dec c
				jr nz,@-x_loop
				
		@offset:ld bc,0
				ex de,hl
				add hl,bc
				ex de,hl
				
				pop bc
				djnz @-y_loop
				
	@rest_lo:	ld a,0
				out (HMPR),a
	@rest_sp:	ld sp,0
				ret

;-------------------------------------------------------
jump.sprite.replace_bgdIX:
; Replace background for sprite at IX.
; Takes data from screen3 to reprint for speed.
@find_frame_data:			
				ld h,( ix + sprite.yH2.os)
				ld l,( ix + sprite.xH2.os)
	@get_depth:
				ld c,( ix + sprite.frame2.width.os)
				ld b,( ix + sprite.frame2.depth.os)
				
			if defined (DEBUG)
				ld a,b									; Quit if depth=0
				or a
				ret z
			endif
			
				ld a,&80
				sub c
				ld ( @+width + 1),a
	@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				ld a,ScreenPage3
				out (HMPR),a
								
	@find_source:
				srl h
				rr l
				ld e,l
				ld d,h
				set 7,h
				
				ld a,b
				ld b,0
	@loop:
				push bc
				ldir
		@width:	ld bc,0
				add hl,bc
				ex de,hl
				add hl,bc
				ex de,hl
				
				pop bc
				dec a
				jr nz,@-loop
				
	@paging:
				ld a,MainPage
				out (HMPR),a
	@rest_sp:	ld sp,0
				ret
				
;-------------------------------------------------------
jump.print.x_clipIX:
@get_pos:
				ld e,( ix + sprite.xH.os)
				ld d,( ix + sprite.yH.os)
@get_source_data:										; Address of source data
				ld l,( ix + sprite.frame.src.os)
				ld h,( ix + sprite.frame.src.os + 1)
				bit 0,e
				jr z,@+get_width_depth
				ld bc,gfx.scroll_data.len
				add hl,bc
@get_width_depth:
				ld c,( ix + sprite.frame.width.os)
				ld b,( ix + sprite.frame.depth.os)
				
@clip_unprintable:										; Test for majorly unprintable objects
				ld a,e
				cp 32
				jr nc,@+left_clip
				add c
				cp 224
				; jr c,@+right_clip

				
@left_clip:
	@find_print_width:
				srl a
				; jr c,@+skip	
				inc a
			@skip:
				ld ( @+print_val + 1),a
	@find_line_down_width:
				neg
				add &80
				ld ( @+update_val + 1),a
	@find_skip_width:
				ld a,e
				neg
				srl a
				ld ( @+skip_val + 1),a
	@get_depth:
				ld e,0
				srl d
				rr e
				
@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				
				ld a,( ix + sprite.frame.page.os)
				ex af,af'
				in a,(HMPR)
				ld ( @+rest_lo + 1),a
				ex af,af'
				out (HMPR),a
				
				ld a,b
@y_loop:
		@skip_val: ld bc,0
				add hl,bc
		@print_val: ld bc,0
				ldir
		@update_val: ld bc,0
				ex de,hl
				add hl,bc
				ex de,hl
				
				dec a
				jr nz,@-y_loop
				
	@rest_lo:	ld a,0
				out (HMPR),a
	@rest_sp:	ld sp,0				
				ret


gfx.print_grab.x_posHLADE:
; Print either unclipped or clipped on right of screen
				ld a,c
				add a
				add e
				jr nc,@+print_all
				jr z,@+print_all
	@print_clipped:										; Set values for moving down a line, amount to print and amount to skip in graphic
				srl a
				; jr c,@+skip
				inc a
			@skip:
				ld ( @+skip_val + 1),a
				neg
				add c
				ld ( @+print_val + 1),a
				; neg
				; add &80
				; ld ( @+update_val + 1),a
				jr @+setup_depth

	@print_all:
				xor a
				ld ( @+skip_val + 1),a
				ld a,c
				ld ( @+print_val + 1),a
				; neg
				; add &80
				; ld ( @+update_val + 1),a
				
@setup_depth:
				srl d
				rr e
@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				
				ld a,( ix + sprite.frame.page.os)
				ex af,af'
				in a,(HMPR)
				ld ( @+rest_lo + 1),a
				ex af,af'
				out (HMPR),a
				
				ld a,b
@y_loop:		
		@print_val: ld bc,0
				ldir
		@skip_val:	ld bc,0
				add hl,bc

				ld bc,&80
				pop de
				ex de,hl
				add hl,bc
				ex de,hl
				
				dec a
				jr nz,@-y_loop
				
	@rest_lo:	ld a,0
				out (HMPR),a
	@rest_sp:	ld sp,0
				ret

;-------------------------------------------------------
jump.clear_grab.x_clipIX:
@get_pos:
				ld a,( ix + sprite.xH2.os)
				add ( ix + sprite.x_offset2.os)
				ld e,a
				ld a,( ix + sprite.yH2.os)
				add ( ix + sprite.y_offset2.os)
				ld d,a
@get_width_depth:
				ld c,( ix + sprite.frame2.width.os)
				ld b,( ix + sprite.frame2.depth.os)
				
@clip_unprintable:
				ld a,( ix + sprite.xB2.os)
				cp 1
				ret p
				cp -1
				ret m
				or a
				jp z,gfx.clear_grab.x_posHLADE
				; x is -ve, test if any of it is printable
				
	@test_printable:									; If xH + width < 0 then quit
				ld a,c									; Get width in bytes
				add a									; Convert to pixels
				add e									; Add to x value
				ret nc									; Skip if printable area not 1 pixel or more
				ret z
				
@x_clip_left:
	@find_print_width:
				srl a
				jr nc,@+skip
				inc a
			@skip:
				ld ( @+print_val + 1),a
	@find_line_down_width:
				neg
				add &80
				ld ( @+update_val + 1),a
	@get_depth:
				xor a
				ex af,af'
				ld a,b
				ld e,0
				srl d
				rr e
				ex de,hl
				
@y_loop:				
				ex af,af'
		@print_val: ld b,0
		@clear_loop:
				ld (hl),a
				inc hl
				djnz @-clear_loop
		@update_val: ld bc,0
				add hl,bc
				
				ex af,af'
				dec a
				jr nz,@-y_loop
				ret


gfx.clear_grab.x_posHLADE:
	@test_right_clip:									; Test if whole vehicle is printable
				ld a,c
				add a
				add e
				jr nc,@+print_all
				jr z,@+print_all
	@print_clipped:										; Set values for moving down a line, amount to print and amount to skip in graphic
				srl a
				jr nc,@+skip
				inc a
			@skip:
				neg
				add c
				ld ( @+print_val + 1),a
				neg
				add &80
				ld ( @+update_val + 1),a
				jr @+setup_depth

	@print_all:
				ld a,c
				ld ( @+print_val + 1),a
				neg
				add &80
				ld ( @+update_val + 1),a
	@setup_depth:
				srl d
				rr e
				ex de,hl
				xor a
				ex af,af'
				ld a,b
@y_loop:		
				ex af,af'
		@print_val: ld b,0
		@clear_loop:
				ld (hl),a
				inc hl
				djnz @-clear_loop
		@update_val: ld bc,0
				add hl,bc
				
				ex af,af'
				dec a
				jr nz,@-y_loop
				ret

;-------------------------------------------------------
jump.credits.copy_downA:
; Copy some lines from background screen to current display screen, starting line A
				ex af,af'
	@paging:
				ld ( @+rest_sp + 1),sp
				ld sp,jump.stack
				in a,(HMPR)
				ld ( @+rest_hi + 1),a
				ld a,ScreenPage3
				out (HMPR),a
				
				ex af,af'
			
	@find_scrn_addr:
				ld h,a
				ld l,0
				srl h
				rr l
				ld e,l
				ld d,h
				set 7,h
				
				ld bc,&80 * 4
				ldir
			
	@paging:
	@rest_hi:	ld a,0
				out (HMPR),a
	@rest_sp:	ld sp,0
				ret

;-------------------------------------------------------
				include "comp.asm"						; Fast print compiler for some sprites
;-------------------------------------------------------
jump.end:
jump.len:		equ jump.end - jump.start
				org jump.src + jump.len
;=======================================================
