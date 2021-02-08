;-------------------------------------------------------
; COMPILER ROUTINES

; NB Cobbled together from R-Type Enemy and Attract compiler routines!!

comp.mod:
;-------------------------------------------------------
comp.gfx.table:											; List of sprite frames to compile
				db sprite.frames.hero + 0, sprite.frames.hero + 1, sprite.frames.hero + 2, sprite.frames.hero + 3
				db sprite.frames.pipe + 0, sprite.frames.extra + 1, sprite.frames.gover, sprite.frames.scenery + 1
				db sprite.frames.numbers + 0, sprite.frames.numbers + 1, sprite.frames.numbers + 2, sprite.frames.numbers + 3
				db sprite.frames.numbers + 4, sprite.frames.numbers + 5, sprite.frames.numbers + 6, sprite.frames.numbers + 7
				db sprite.frames.numbers + 8, sprite.frames.numbers + 9
comp.gfx.table.short:									; Only compile one frame if not running full game
				db sprite.frames.extra + 0
				db eof
				
				ds align &100
comp.jump_tab:											; vertical table of quick routines !! Better explanation needed
				ds &600									; Page, Jump address, scrolled version page, jump address

				ds &40									; Special stack, doesn't collide with jump stack or build page
comp.stack:
			if defined (DEBUG)
				nop
			endif

comp.x_tally:	db 0									; Tally of x-offset in bytes to next printed byte
comp.y_tally:	db 0									; Same, as for y-offset
comp.depth:		db 0									; Depth of current frame to compile
comp.width:		db 0									; Width of current frame to compile

;-------------------------------------------------------
comp.create:
; Compile list of sprites at .gfx.table, fill LUT at .jump_tab, and compile the routines.
; This starts at base page of GfxPage3 and works up automatically
@paging:				
				ld ( @+rest_sp + 1),sp
				ld sp,comp.stack
@clear_buffer:
				ld hl,0
				ld de,1
				ld bc,40 * &80
				ld (hl),0
				ldir

@init_page_tally:
				ld ix,(compile.addr)
				ld iy,comp.gfx.table
				ld a,(auto.512K)
				or a
				jr z,@+skip
				ld iy,comp.gfx.table.short				; If extra memory not found, 
			@skip:
				ld hl,comp.jump_tab						; Lookup table for printing these sprites
@loop:				
	@get_src:											; Get frame number to compile
				ld a,(iy)
				cp eof
				jr z,@+end

				ld h,comp.jump_tab / &100				; Compile 1st version, entry in top of qprint jump table
				ld de,0
				call @+compileHDEIY
				ld h,(comp.jump_tab / &100) + 3			; Compile 2nd scrolled version to next entry in qprint jump table
				ld de,1
				call @+compileHDEIY
	@next_frame:
				inc iy
				jp @-loop
				
@end:
				ld (compile.addr),ix
				
				in a,(HMPR)
				ld ( @+rest_hi + 1),a
	@copy_table:										; Copy jump table under other screen
				in a,(LMPR)
				and %00011111
				xor 2
				out (HMPR),a
				ld hl,comp.jump_tab
				ld de,comp.jump_tab + &8000
				ld bc,&600
				ldir
				
	@rest_hi:	ld a,0
				out (HMPR),a
	@rest_sp:	ld sp,0
				ret

;-------------------------------------------------------
@compileHDEIY:
; Compile a routine, add entry to vertical table.
; DE = screen address to print frame
; IY = frame data in table
; H = MSB of table entry to 
				push de
				push hl
	@compile_clip_right:
	@store_table_entry:
				ld l,(iy)								; Use frame number as index in vertical list (max 256 frames?  Enough?)
				ld a,(compile.page) 					; Store page
				ld (hl),a
				inc h
				ld a,ixl								; Store routine address
				ld (hl),a
				inc h
				ld a,ixh
				ld (hl),a
	@print_to_buffer:									; Use slow print to print source (source paged out to output compiled code anyway)
				ld a,(iy)
				push ix
				call jump.print_frameADE
				pop ix
	@compile:
				call comp.clip_right_maskIXIY 			; Compile routine
				call @+upd_comp_page					; Check compile page hasn't overspilled into next page
				call @+clear_buffer
				pop hl
				pop de
				
	@compile_clip_left:			
	@store_table_entry:
				ld l,(iy)
				set 7,l
				ld a,(compile.page) 		
				ld (hl),a
				inc h
				ld a,ixl					
				ld (hl),a
				inc h
				ld a,ixh
				ld (hl),a
	@print_to_buffer:						
				ld a,l
				and %01111111
				push ix
				call jump.print_frameADE
				pop ix
	@compile:
				call comp.clip_left_maskIXIY
				call @+upd_comp_page
				call @+clear_buffer
				ret
				
@upd_comp_page:
; Check compile address.  If moved onto new page, update tally.
				ld a,ixh
				cp &c0									; New page at &c000 (16K into high memory)
				ret c
	@new_page:
				sub &40
				ld ixh,a
				ld a,(compile.page)
				inc a
				ld (compile.page),a
				ret
				
@clear_buffer:
				ld hl,0
				ld de,1
				ld bc,&0b00 - 1
				ld (hl),0
				ldir
				ret

;-------------------------------------------------------		
comp.clip_right_maskIXIY:
; Compile quick print routine masking each pixel, printing and checking for right-clipping
; On entry, IX points to compile address, IY points to attract.logo_data field.  Logo is assumed to be printed at &0000.
				push iy
@find_frame_data:										; Find sprite frame information
				ld h,0
				ld l,(iy)
				for 3,add hl,hl
				ex de,hl
				ld iy,sprite.frames
				add iy,de
				
@set_src_vars:
				ld de,0									; screen position to start from	
				ld c,( iy + sprite.frames.width.os)
				ld b,( iy + sprite.frames.depth.os)
				srl b
				inc b									; Always round up to even number of rows
		
@get_dest:		
				ld a,ixh								; Get destination to compile to from ix
				ld h,a
				ld a,ixl
				ld l,a
			
@page_in_src:											; Attract graphics compiled to GfxPage4
				ld ( @rest_stack + 1),sp
				ld a,(compile.page)
				out (HMPR),a
				ld sp,&8000
						
				call @comp_setBC						; LD BC,&80  for easy swapping of odd- to even-y-coords
				call @+comp_set_counter					; Calculate how many columns to print, store in E
@x_loop:
				push bc
				dec b
				push bc
	@y_loop:											; Loop down a column, do all even-y-coords values first
				call @+comp_print_byte_masked
				call @+comp_2down
				djnz @-y_loop
				call @+comp_print_byte_masked
				
				call @+comp_update_move_tally
				call @+comp_1down						; Swap to odd-y-coords
				pop bc
	@y_loop2:											; Loop back up all odd-y-coords
				call @+comp_print_byte_masked
				call @+comp_2up
				djnz @-y_loop2
				call @comp_print_byte_masked
				
				call @+comp_update_move_tally
				call @+comp_1up							; Swap back to even-y-coords
				pop bc
				
				call @+comp_2right_test					; Move right 2 pixels until counter has run out
				dec c
				jp nz,@-x_loop
				
				call @+comp_ret
				
@paging:
				ld a,MainPage
				out (HMPR),a
	@rest_stack: ld sp,0
			
				ld a,l									; Return IX pointing to next free compile address
				ld ixl,a
				ld a,h
				ld ixh,a
				
				pop iy
				ret

;-------------------------------------------------------
@comp_setBC:
; Compile pre-load BC, as this is used once per 2-pixel column
				ld (hl),ld_bc.nn
				inc hl
				ld (hl),&80
				inc hl
				ld (hl),0
				inc hl
				ret
				
;-------------------------------------------------------
@comp_print_byte_masked:
; Print this byte.  Mask palette 0 on either nibble
	@test_blank:
				ld a,(de)
				or a
				ret z
				
	@check_left_nibble:									; Check left nibble
				and %11110000
				jp nz,@+check_right_nibble				; If present, check right nibble
				
		@print_right:									; Print only right pixel (source not blank, and no left pixel)
				call @+comp_update_move_tally			; Compile any outstanding movement code
				ld a,(de)								; Get source
				
				ld (hl),ld_a..hl.						; strip background 
				inc hl
				ld (hl),and_n
				inc hl
				ld (hl),%11110000
				inc hl
				ld (hl),or_n							; merge with data
				inc hl
				ld (hl),a
				inc hl
				ld (hl),ld_.hl..a						; Store result
				inc hl
				ret
				
	@check_right_nibble:								; Left pixel is present.  Test right pixel too
				ld a,(de)
				and %00001111
				jp nz,@+print_whole_byte				; If right pixel present, skip to print whole byte
				
		@print_left:
				call @+comp_update_move_tally			; Otherwise just print left pixel
				ld a,(de)
				
				ld (hl),ld_a..hl.						; Get background
				inc hl
				ld (hl),and_n
				inc hl
				ld (hl),%00001111						; Mask left pixel
				inc hl
				ld (hl),or_n							; Add in source left pixel
				inc hl
				ld (hl),a
				inc hl
				ld (hl),ld_.hl..a						; Reapply
				inc hl
				ret
				
	@print_whole_byte:									; Neither pixel is masked, just move the data directly
				call @+comp_update_move_tally
				ld (hl),ld_.hl..n
				inc hl
				ld a,(de)
				ld (hl),a
				inc hl
				ret				

;-------------------------------------------------------
@comp_set_counter:
; Work out how many 2-pixel columns to print.  Set to E
; LD A,112; SUB L; AND %01111111; LD E,A
				ld a,&70
				ld (hl),ld_a.n
				inc hl
				ld (hl),a
				inc hl
				ld (hl),sub_l
				inc hl
				ld (hl),and_n
				inc hl
				ld (hl),%01111111
				inc hl
				ld (hl),ld_e.a
				inc hl
				ret

;-------------------------------------------------------
@comp_2right_test:
; Move right 2 pixels, return if counter has run out
				ld (hl),inc_l
				inc hl
				ld (hl),dec_e
				inc hl
				ld (hl),ret_z
				inc hl
				inc e
				ret

;-------------------------------------------------------
@comp_2down:
; Update tally of 2-rows moved since last pixel printed
				ld a,(comp.y_tally)
				inc a
				ld (comp.y_tally),a
				
				inc d									; Move down source as well
				ret

;-------------------------------------------------------
@comp_2up:
; Update tally of 2-rows moved since last pixel printed
				ld a,(comp.y_tally)
				dec a
				ld (comp.y_tally),a
				
				dec d
				ret

;-------------------------------------------------------				
@comp_update_move_tally:
; Take tally of skipped lines and compile a speed-optimised jump to next line to print
@test_no_movement:										; If no movement needed, quit immediately
				ld a,(comp.y_tally)
				cp 0
				ret z
				jp m,@+move_up							; If negative value, compile move upwards
				
@move_down:												; Check size of jump
				cp 3
				jp nc,@+big_jump
	@small_jump:										; For small jumps, better to compile INC H up to 3 times.
				ld (hl),inc_h
				inc hl
				dec a
				jp nz,@-small_jump
				ld (comp.y_tally),a						; Clear tally before quitting
				ret

	@big_jump:											; If 3 or larger, more efficient to compile LD A,H; ADD n; LD H,A
				ld (hl),ld_a.h
				inc hl
				ld (hl),add_n
				inc hl
				ld (hl),a
				inc hl
				ld (hl),ld_h.a
				inc hl
				xor a									; Clear the tally
				ld (comp.y_tally),a
				ret

@move_up:												; Same logic for moving upwards, with some tokens changed
				neg
				cp 3
				jp nc,@+big_jump
	@small_jump:
				ld (hl),dec_h							; DEC H to move upward
				inc hl
				dec a
				jp nz,@-small_jump
				ld (comp.y_tally),a
				ret
	@big_jump:
				ld (hl),ld_a.h
				inc hl
				ld (hl),sub_n							; SUB N to move upwward
				inc hl
				ld (hl),a
				inc hl
				ld (hl),ld_h.a
				inc hl
				xor a
				ld (comp.y_tally),a
				ret

;-------------------------------------------------------
@comp_1down:
; Go down one line
				ld (hl),add_hl.bc
				inc hl
				
				ex de,hl
				push bc
				ld bc,128
				add hl,bc
				pop bc
				ex de,hl
				ret

;-------------------------------------------------------
@comp_1up:
; Go up one line.  !  Possible bug, doesn't reset carry beforehand
				ld (hl),&ed								; sbc_hl.bc
				inc hl
				ld (hl),&42
				inc hl
				
				ex de,hl
				push bc
				ld bc,-&80
				add hl,bc
				pop bc
				ex de,hl
				ret

;-------------------------------------------------------				
@comp_ret:
; Compile RET 
				ld (hl),ret_
				inc hl
				ret
				
;=======================================================
; COMP CLIP LEFT

;-------------------------------------------------------		
comp.clip_left_maskIXIY:
; Compile quick print routine masking each pixel, printing and checking for left-clipping
; On entry, IX points to compile address, IY points to attract.logo_data field.  Logo is assumed to be printed at &0000.
				push iy
@find_frame_data:										; Find sprite frame information
				ld h,0
				ld l,(iy)
				for 3,add hl,hl
				ex de,hl
				ld iy,sprite.frames
				add iy,de
				
@set_src_vars:
				ld de,0									; screen position to start from	
				ld c,( iy + sprite.frames.width.os)
				ld b,( iy + sprite.frames.depth.os)
				srl b						
				inc b									; Always round up to even number of rows					
		
@get_dest:		
				ld a,ixh								; Get destination to compile to from ix
				ld h,a
				ld a,ixl
				ld l,a
			
@page_in_src:											; Attract graphics compiled to GfxPage4
				ld ( @rest_stack + 1),sp
				ld a,(compile.page)
				out (HMPR),a
				ld sp,&8000
						
				call @-comp_setBC						; LD BC,&80  for easy swapping of odd- to even-y-coords
				call @+comp_set_counter_left			; Calculate how many columns to print, store in E, find rhs of graphic to print
@x_loop:
				push bc
				dec b
				push bc
	@y_loop:											; Loop down a column, do all even-y-coords values first
				call @-comp_print_byte_masked
				call @-comp_2down
				djnz @-y_loop
				call @-comp_print_byte_masked
				
				call @-comp_update_move_tally
				call @-comp_1down						; Swap to odd-y-coords
				pop bc
	@y_loop2:											; Loop back up all odd-y-coords
				call @-comp_print_byte_masked
				call @-comp_2up
				djnz @-y_loop2
				call @-comp_print_byte_masked
				
				call @-comp_update_move_tally
				call @-comp_1up							; Swap back to even-y-coords
				pop bc
				
				call @+comp_2left_test					; Move right 2 pixels until counter has run out
				dec c
				jp nz,@-x_loop
				
				call @-comp_ret
				
@paging:
				ld a,MainPage
				out (HMPR),a
	@rest_stack: ld sp,0
			
				ld a,l									; Return IX pointing to next free compile address
				ld ixl,a
				ld a,h
				ld ixh,a
				
				pop iy
				ret

;-------------------------------------------------------
@comp_set_counter_left:
; Work out how many 2-pixel columns to print.  Set to E as counter.  Leave L on right-hand-side
; LD A,L; ADD n (width in C); LD L,A; AND %01111111; SUB &10 - 1; LD E,A; RET Z; RET NC
				dec c
				
				ld (hl),ld_a.l
				inc hl
				ld (hl),add_n
				inc hl
				ld (hl),c
				inc hl
				ld (hl),ld_l.a
				inc hl
				ld (hl),and_n
				inc hl
				ld (hl),%01111111
				inc hl
				ld (hl),sub_n
				inc hl
				ld (hl),&0f
				inc hl
				ld (hl),ld_e.a
				inc hl
				ld (hl),ret_z
				inc hl
				ld (hl),ret_c
				inc hl
				
				ld e,c
				
				inc c
				ret

;-------------------------------------------------------
@comp_2left_test:
; Move left 2 pixels, return if counter has run out
				ld (hl),dec_l
				inc hl
				ld (hl),dec_e
				inc hl
				ld (hl),ret_z
				inc hl
				
				dec e
				ret

;-------------------------------------------------------
comp.end:
comp.len:		equ comp.end - comp.mod
