;-------------------------------------------------------
; FONT PRINTING

;	font.print_string			Print string.  HL->Message, terminated with EOF.  (E,D) coords.  Font A
;	font.print_stringHL			Print string with header.  Byte 0=font number.  Byte 1: X coord, byte 2: Y coord
;	font.print_string.colHLDE	Print string colourised...... !!! Add instructions
; 	font.print_char				Print single character A at (E,D), with current font
;	font.print_hex_byteDEA		Print A as hex byte, at DE
;	font.print_hex_wordHLDE		Print HL as hex word, at DE

cr:				equ 13
quote:			equ 34
cr_depth:		equ 10									; How many pixels down a carriage return executes

;-------------------------------------------------------
font.data:
				include "completed gfx/font data.asm"
font.data.end:
font.data.scrolled:
				include "completed gfx/font data.asm"	; Have a second version to scroll right one pixel
font.data.len:	equ font.data.end - font.data

				ds align 256
font.colourise_table:
				for 256, db 0
				
;-------------------------------------------------------
font.set_masked:
; Set masked print type, 0 assumed to be background on font
				ld hl,@+masked_print
				ld ( @+print_type + 1),hl
				ret

font.set_simple:
; Set unmasked print
				ld hl,@+simple_print
				ld ( @+print_type + 1),hl
				ret
				
font.set_colourisedHL:
; Set colourised print: set 16 byte colour table at HL to replace colours as printed.
				ld de,@+colourised_print
				ld ( @+print_type + 1),de
				
@set_right_nibble:
				push hl
				
				ld de,font.colourise_table
				ld a,16
	@loop1:
				push hl
				ld bc,16
				ldir
				pop hl
				dec a
				jr nz,@-loop1

				pop hl
				
@set_left_nibble:
				ld de,font.colourise_table
				ld c,16
	@loop2:
				ld a,(hl)
				for 4,add a
				ld ( @+top_nib + 1),a
				
				ld b,16
		@loop3:
				ld a,(de)
		@top_nib: or 0
				ld (de),a
				inc de
				djnz @-loop3
				
				inc hl
				dec c
				jp nz,@-loop2
				ret

;-------------------------------------------------------
font.set_colA:
; Set colour A - only works for simple white fonts
				push bc
				ld c,a
				for 4,add a
				or c
				ld ( @+colour_val + 1),a
				pop bc
				ret

;-------------------------------------------------------
font.print_string.colHL:
; printing with colourised text
				ld a,(hl)
				ld ( @+colour_val + 1),a				; Use font data as mask, AND with colour needed
				inc hl

font.print_stringHL:
; Print at coords in message at HL
				ld e,(hl)								; Get coords to print at
				inc hl
				ld d,(hl)
				inc hl

font.print_stringHLDE:
; Print string at HL, at coords DE.
				push de
	@chr_loop:
		@get_chr:
				ld a,(hl)
				inc hl
		@check_end_token:
				cp eof
				jp z,@+quit
		@check_CR_token:
				cp cr
				jp nz,@+skip_cr
		@carriage_return:
				pop de
				ld a,cr_depth
				add d
				ld d,a
				push de
				jp @-chr_loop
		@skip_cr:
				call font.print_charADE
				jp @-chr_loop
	@quit:
				pop de
				ret

;-------------------------------------------------------
font.print_charADE:
; Print ASCII character A at DE
				ld ixh,font.colourise_table / &100
	@test_space:
				cp " "
				jp nz,@+print
		@space:
				ld a,4
				add e
				ld e,a
				ret
	@print:
				cp 4
				jp nc,@+next
		@set_colour:
				call font.set_colA
				ret
		@next:
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
	@colour_val: ld c,&ff								; mask colour value
	@print_loop:										; Print 7*5 character
				push bc

				ld b,4
	@char_loop:
	@print_type: call @+masked_print

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

@simple_print:
				ld a,(hl)
				and c									; Colourise each byte
				ld (de),a
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

@colourised_print:										; NB Colourised print also masks 
				push bc
	@top_pix:
				ld a,(hl)
				ld ixl,a
				ld a,(ix)
				and %11110000
				jp nz,@+next
	@background:
				ld a,(de)
				and %11110000
	@next:
				ld b,a
	@bottom_pix:
				ld a,(hl)
				ld ixl,a
				ld a,(ix)
				and %00001111
				jp nz,@+next
	@background:
				ld a,(de)
				and %00001111
	@next:
				or b
				ld (de),a

				pop bc
				ret

;-------------------------------------------------------
font.print_hex_byteADE:
; Print A as a hexadecimal number, at coords DE
				push af
	@top_nibble:
				for 4,rra
				and %00001111
				ld c,a
				ld b,0
				ld hl,font.hex_string
				add hl,bc
				ld a,(hl)
				call font.print_charADE
	@bottom_nibble:
				pop af
				and %00001111
				ld c,a
				ld b,0
				ld hl,font.hex_string
				add hl,bc
				ld a,(hl)
				call font.print_charADE
				ret

font.print_hex_wordHLDE:
; Print HL as a hexadecimal number, at coords DE
				push hl
				ld a,h
				call font.print_hex_byteADE
				pop hl
				ld a,l
				call font.print_hex_byteADE
				ret

font.hex_string: dm "0123456789ABCDEF"

;-------------------------------------------------------
font.ascii_table:
; Offset in sprite lengths (all font frames are same length), and X-width including outlines
				db 0,4									; space		!! Not sure of width
				db 62,3									; !
				db 74,5									; "
				db 0,0									; £
				db 0,0									; $
				db 0,0									; %
				db 78,7									; &
				db 73,3									; '
				db 64,4									; (
				db 65,4									; )
				db 70,5									; *
				db 68,5									; +
				db 67,4			 						; ,
				db 69,6									; -
				db 66,3									; .
				db 71,7									; /
				db 52,6									; 0
				db 53,4									; 1
				db 54,6									; 2
				db 55,6									; 3
				db 56,6									; 4
				db 57,6									; 5
				db 58,6									; 6
				db 59,6									; 7
				db 60,6									; 8
				db 61,6									; 9
				db 75,3									; :
				db 76,4									; ;
				db 0,0									; <
				db 72,6									; =
				dw 0									; >
				db 63,6									; ?
				db 77,7			 						; @
				db 0,6									; A
				db 1,6									; B
				db 2,5									; C
				db 3,6									; D
				db 4,5									; E
				db 5,5									; F
				db 6,6									; G
				db 7,6									; H
				db 8,5									; I
				db 9,6									; J
				db 10,6									; K
				db 11,6									; L
				db 12,7									; M
				db 13,6									; N
				db 14,6									; O
				db 15,6									; P
				db 16,6									; Q
				db 17,6									; R
				db 18,6									; S
				db 19,5									; T
				db 20,6									; U
				db 21,6									; V
				db 22,7									; W
				db 23,6									; X
				db 24,6									; Y
				db 25,5									; Z
				db 79,5									; [ (top heart)
				db 71,7									; /
				db 80,5									; ] (bottom heart)
				db 0,0 									; ^
				db 0,0									; _
				db 0,0									; `
				db 26,6									; a
				db 27,6									; b
				db 28,5									; c
				db 29,6									; d
				db 30,6									; e
				db 31,5									; f
				db 32,6									; g
				db 33,6									; h
				db 34,3									; i
				db 35,4									; j
				db 36,6									; k
				db 37,3									; l
				db 38,7									; m
				db 39,6									; n
				db 40,6									; o
				db 41,6									; p
				db 42,6									; q
				db 43,5									; r
				db 44,6									; s
				db 45,5									; t
				db 46,6									; u
				db 47,6									; v
				db 48,7									; w
				db 49,5									; x
				db 50,6									; y
				db 51,6									; z	

;-------------------------------------------------------
