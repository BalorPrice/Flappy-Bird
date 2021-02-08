debug.mod:
;-------------------------------------------------------
; DEBUG TOOLS

			if defined (DEBUG)							; Whole module will be missed out of final build
;-------------------------------------------------------
debug.spare.coords2:		equ &b9b8

debug.sprite.msg:	dm "  :     :    :    "
				db eof

;-------------------------------------------------------
debug.print_all:
; Print all the debug data that's switched on
				call debug.print.sprite_data
				call debug.print_sprite_count
				ret
				
;-------------------------------------------------------
debug.print.sprite_data:
	@check_active:
				ld a,sprite_data.on
				cp Off
				ret z
				
				ld ix,(sprite.ll.first)
				call font.set_simple
				ld a,orange * &11
				call font.set_colA
				ld de,0
				ld a,0
	@loop:
				push af
				push af
				ld e,0
				ld hl,debug.sprite.msg
				call font.print_stringHLDE
				pop af
				ld e,0
				call font.print_hex_byteADE
				ld l,( ix + sprite.prev.os)
				ld h,( ix + sprite.prev.os + 1)
				ld e,8 * 4
				call font.print_hex_wordHLDE
				ld a,ixl
				ld l,a
				ld a,ixh
				ld h,a
				ld e,8 * 9
				call font.print_hex_wordHLDE
				ld l,( ix + sprite.next.os)
				ld h,( ix + sprite.next.os + 1)
				ld e,8 * 14
				push hl
				call font.print_hex_wordHLDE
				pop hl
				ld a,l
				and h
				cp -1
				jr z,@+end
				
				push de
				call sprite.ll.goto_nextIX
				pop de
				ld a,8
				add d
				ld d,a
				
				pop af
				inc a
				jp @-loop
				
	@end:
				pop af
				ret
	
;-------------------------------------------------------
debug.print_sprite_count:
; Print count of sprite objects processed
	@check_active:
				ld a,sprite_count.on
				cp Off
				ret z
				
				call font.set_simple
				ld a,orange
				call font.set_colA
				ld a,(sprite.ll.count)
				ld de,debug.spare.coords2
				call font.print_hex_byteADE
				ret
				
;--------------------------------------------------------
			endif
