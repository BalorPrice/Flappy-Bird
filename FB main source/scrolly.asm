;-------------------------------------------------------
; SCROLLY

; Extremely quickly hacked together!  TODO - rename variables to actually make sense
;-------------------------------------------------------
scrolly.text:
				dm "SAM version - Cooking Circle 2021"
				db eof
				
scrolly.512k_only.text:
				dm " [Sorry! This needs 512K to run]"
				db eof
		
				
scrolly.y:				equ map.y.bottom + 20			; Top-left coords of banner area
scrolly.x:				equ 58
scrolly.coords:			equ (scrolly.y * &100 + scrolly.x - 1) 	; Address of top-left of banner onscreen
scrolly.clear.addr:		equ (scrolly.y * &100 + 32) / 2

scrolly.delay:			db 0							; Countdown to start printing
scrolly.init.delay:		equ 255							; How long to wait before printing

scrolly.pos:			dw scrolly.text					; Address of current message to print
scrolly.pos.next:		dw 0							; Address of next message to print
scrolly.print.done:		db 0							; If in printing mode, is the current message finished printing?
scrolly.on:				db No

;-------------------------------------------------------
scrolly.init:
; Reset bottom banner
				ld hl,scrolly.text
				ld b,scrolly.init.delay					; Nice long delay so attract screen is absorbed before attention diverted
	@test_memory_msg:									; If 512k not found, change message 
				ld a,(auto.512K)
				or a
				jr z,@+reset_pos
		@set_512k_only:									; Alt message and timing if not enough memory found
				ld hl,scrolly.512k_only.text
				ld b,1
	@reset_pos:											; Set text to start again
				ld (scrolly.pos),hl
				ld a,b
				ld (scrolly.delay),a
				ld a,No
				ld (scrolly.print.done),a
				ld hl,scrolly.coords
				ld ( @+buffer_pos + 1),hl
				ld a,1
				ld ( @+screen_tally + 1),a
				ld a,Yes
				ld (scrolly.on),a
				ret
				
;-------------------------------------------------------
scrolly.update:
; Print next message to scroll buffer
; This needs to be broken up to only print a couple of letters each frame, then no loss in performance
	@check_active:
				ld a,(scrolly.on)
				cp No
				ret z
	@update_delay:
				ld a,(scrolly.delay)
				or a
				jr z,@+check_printed
				dec a
				ld (scrolly.delay),a
				ret 
	@check_printed:			
				ld a,(scrolly.print.done)
				cp Yes
				ret z

	@get_letter:
	@buffer_pos: ld de,0
				ld hl,(scrolly.pos)
				ld a,(hl)
				cp eof
				jr z,@+end_message
				call attract.print_charADE.buffer
	@set_next_print:
	@screen_tally: ld a,0
				inc a
				and %00000011
				ld ( @-screen_tally + 1),a
				or a
				ret nz
				inc hl
				ld (scrolly.pos),hl
				ld ( @-buffer_pos + 1),de
				ret
	@end_message:
				ld a,Yes
				ld (scrolly.print.done),a
				ret

;-------------------------------------------------------
attract.print_charADE.buffer:
; Print ASCII character A at DE in buffer
	@test_space:
				cp " "
				jp nz,@+print
		@space:
				ld a,4
				add e
				ld e,a
				ret
	@print:
				push de
				push hl
	@get_src_data:										; Find source graphic data from ascii code
				sub " "
				add a
				ld l,a
				ld h,0
				ld bc,font.ascii_table
				add hl,bc
				
				ld a,(hl)
				inc hl
				push hl
	@mult36:
				ld l,a
				ld h,0
				ld c,l
				ld b,h
				for 3, add hl,hl
				add hl,bc
				for 2,add hl,hl
				ld bc,font.data
				add hl,bc

	@find_screen_address:								; Translate coords into screen address
				srl d
				rr e
				jr nc,@+skip
				ld bc,font.data.len
				add hl,bc
		@skip:
		
				ld b,9
				ld c,&ff
	@print_loop:										; Print character
				push bc

				ld b,4
	@char_loop:
				call @+masked_print

				inc hl
				inc de
				djnz @-char_loop

				ld bc,&80 - 4
				ex de,hl
				add hl,bc
				ex de,hl
				
				pop bc
				djnz @-print_loop

	@end_letter:
				pop hl
				ld a,(hl)
				dec a
				pop hl
	@next_letter_pos:
				pop de
				add e
				ld e,a
				ret

@masked_print:
				push bc
	@top_pix:
				ld a,(hl)
				and %11110000
				jp nz,@+colour
	@background:
				ld a,(de)
				and %11110000
				jp @+next
	@colour:
				and c
	@next:
				ld b,a
	@bottom_pix:
				ld a,(hl)
				and %00001111
				jp nz,@+colour
	@background:
				ld a,(de)
				and %00001111
				jp @+next
	@colour:
				and c
	@next:
				or b
				ld (de),a

				pop bc
				ret

;-------------------------------------------------------
scrolly.clear.init:
				ld a,18									; This scroll should take 18 frames to move 9 pixels
				ld (scrolly.delay),a
				ret
				
;-------------------------------------------------------
scrolly.clear:
				ld a,(scrolly.delay)
				or a
				ret z
				dec a
				ld (scrolly.delay),a
				
				ld de,scrolly.clear.addr				; Top-left address of banner onscreen
				ld hl,scrolly.clear.addr + &80			; Address of one pixel down
				ld a,9
	@loop:
				for &60 - 1, ldi
		@next_line:
				ld bc,&20 + 1
				add hl,bc
				ex de,hl
				add hl,bc
				ex de,hl
				
				dec a
				jp nz,@-loop
				ret		

;-------------------------------------------------------