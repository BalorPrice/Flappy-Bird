; REDEFINE KEYS

;----------------------------------------------
@top_line:		equ &30
@line_gap:		equ &0c
@left_align:	equ &18
@right_align:	equ &88
@pause:			equ &0a
@end_pause:		equ &2d

redefine.msg:
				dm ""
				db eof
				dm ""
				db eof
				dm ""
				db eof
				dm ""
				db eof 
				dm ""
				db eof
				dm ""
				db eof
				
redefine.offsets:
				db 7-Left,7-Right,7-Up,7-Down,7-Fire,7-F9
				
redefine.keyvals:								; Temporary list of keyvalues, to check not duplicating 
				db 0,0,0,0,0,0

				;Key no. >  0     1     2     3     4     5     6     7
				;Key row \/			   
				;0.         1     2     3     4     5     ESC   TAB   CAPS
				;1.         Q     W     E     R     T     F7    F8    F9
				;2.         A     S     D     F     G     F4    F5    F6
				;3.         SHIFT Z     X     C     V     F1    F2    F3
				;4.         0     9     8     7     6     -     +     DEL
				;5.         P     O     I     U     Y     =     "     F0
				;6.         ENTER L     K     J     H     ;     :     EDIT
				;7.         SPACE SYMBL M     N     B     ,     .     INV
				;8.         CTRL  UP    DOWN  LEFT  RIGHT

;----------------------------------------------
redefine.k_scanHL:
; Steve Taylor's key scan routine.  

; Read 8 keydefinitions at HL (see table), output C with each respective bit set if key pressed.
; Used for reading keys stored from redefine keys routine.
				ld bc,&800						; Repeat for each of 8 rows
@k_scan1:
	@get_row_number:
				ld a,(hl)
				inc hl
				ld e,a
				for 3,srl e
				ld d,0
				
                push hl
                ld hl,@key_addresses			; Get port number from key_addresses table
                add hl,de
                ld d,a
				
                push bc
	@get_key_port_half:							; Get lower 5 bits from keyboard port
                ld c,KeyboardReg
                ld b,(hl)
                in a,(c)
                and %00011111
                ld e,a
	@get_status_port_half:						; Get upper 3 bits from status port
                ld c,StatusReg
                in a,(c)
                and %11100000
	@merge_inputs:								; merge two together
                or e
                cpl  
                ld e,a
                pop bc
				
                pop hl
                ld a,d
                and %00000111
                jr z,@k_scan3
@k_scan2:										; Rotate input into destination bit position
				rr e
				dec a
				jr nz,@k_scan2
@k_scan3:										; Rotate into main output C
				rr e
				rl c
				djnz @k_scan1					; Repeat for each key
				ret  							; Return C with output
				
@key_addresses:	db &f7,&fb,&fd,&fe,&ef,&df,&bf,&7f,&ff	; List of ports to read for keypresses

;----------------------------------------------				
keys.redefine:
; Assume redefined keys override predefined keys, so any keys are fine.
				; push af
				; call @+clear_lower
				; call @+reset
; @setup_loop:
				; ld b,6							; Six keys to redefine
				; ld iy,keys.redef				; Output to keys.redef table
				; ld ix,redefine.offsets			; List of offsets to store keys in keys.redef table
				; ld hl,redefine.msg				; Message to print
				; ex af,af'						
				; ld a,@top_line					; Set top print line
				; ex af,af'	
; @redef_key:
				; push bc
				
; @print_challenge:								; Print key input message
				; push af
				; ld a,green*&11
				; call font.set_colA
				; pop af
	; @set_x_print_pos:
				; ld e,@left_align
				; ex af,af'
				; ld d,a
				; ex af,af'
				; xor a
				; call font.print_stringHLDE

				; push hl
; @scan_loop:										; Scan for key pressed
				; ld hl,@key_addresses+8
				; ld d,9
	; @scan_ports:								; Collect keyrow inputs from both registers
				; ld b,(hl)
				; ld c,StatusReg
				; in a,(c)
				; cpl
				; and %11100000
				; ld e,a
				; ld c,KeyboardReg
				; in a,(c)
				; cpl
				; and %00011111
				; or e
				
				; ld b,8							; Loop through each bit to see if set
	; @keyscanloop:
				; rlca
				; jr c,@+next
				; djnz @-keyscanloop
				
				; dec hl							; If nothing pressed, move to next keyrow to test
				; dec d
				; jr nz,@-scan_ports
				; jr @-scan_loop
				
	; @next:
				; call @+allocate					; Allocate pressed key
				; jr z,@-scan_loop				; If key already allocated keep scanning
				; call @+print_key				; Print confirmation feedback
				
				; push de
				; xor a
				; ld b,9
		; @clear_loop:
				; ld (de),a
				; inc de
				; djnz @-clear_loop
				
				; pop de
				
		; @move_loop:
				; ld a,(hl)
				; cp eof
				; jp z,@+next
				; ld (de),a
				; inc hl
				; inc de
				; jp @-move_loop
		; @next:
				
				; ld b,@pause
				; call house.wait_B_frames_im2
				
				; pop hl
				; pop bc
				; dec b
				; jp nz,@-redef_key
				
				; ld b,@end_pause
				; call house.wait_B_frames_im2
				
				; call house.clear_screens
				
				; pop af
				ret


@clear_lower:
; Clear lower part of screen
				; ld hl,38*128
				; ld de,38*128+1
				; ld (hl),0
				; ld bc,(192-38)*128-1
				; ldir
				ret
				
@reset:				
; Clear store address and redef table
	@reset_store_addr:							; Reset table of keys positions
				; ld hl,attract.keys.pos
				; ld (redefine.store_addr+1),hl
	; @clear_redef_table:  						; Clear keycodes table
				; ld hl,keys.redef
				; ld de,keys.redef+1
				; ld (hl),255
				; ld bc,8-1
				; ldir
	; @clear_keyvalue_table:   					; Clear temporary store of used keys
				; ld hl,redefine.keyvals
				; ld (redefine.keyvals.pos+1),hl
				; ld de,redefine.keyvals+1
				; ld (hl),0
				; ld bc,6-1
				; ldir
				ret

@allocate:
; Translate D into keyvalue
	; @translate_input:
				; ld a,d
				; dec a
				; for 3,add a	
				; dec b
				; or b
	; @test_escape:
				; cp 5							; Test escape as single undefinable key
				; ret z
	; @check_keyvalue:							; If keyvalue already used, return
				; ld hl,redefine.keyvals
				; ld b,6
		; @loop:
				; cp (hl)
				; ret z
				; inc hl
				; djnz @-loop
	; @store_keyvalue:							; Put current keyvalue into table of used values
; redefine.keyvals.pos: ld hl,0
				; ld (hl),a
				; inc hl
				; ld (redefine.keyvals.pos+1),hl
				
	; @store_keycode:								; Set iy offset to store to correct position
				; ld e,a
				; ld a,(ix)
				; inc ix
				; ld (@+offset+2),a
				; ld a,e
		; @offset: ld (iy+0),a
				; cp 255							; Return NZ
				ret

@print_key:
; Print the new definition message
				; push af
				; ld a,white*&11
				; call font.set_colA
				; pop af
	; @find_msg:
				; add a
				; ld l,a
				; ld h,0
				; ld de,redefine.key_msg.table
				; add hl,de
				; ld e,(hl)
				; inc hl
				; ld d,(hl)
				; ex de,hl
	; @find_print_pos:
				; push hl
				; ld e,@right_align
				; ex af,af'
				; ld d,a
				; add @line_gap					; Next line down
				; ex af,af'
				; xor a
				; call font.print_stringHLDE
				
	; @store_msg:									; store defined name 
; redefine.store_addr: ld hl,attract.keys.pos
				; ld e,(hl)
				; inc hl
				; ld d,(hl)
				; inc hl
				; ld (redefine.store_addr+1),hl
				; pop hl
				
				ret
				
;----------------------------------------------
redefine.key_msg.table:
; Lookup table so when key is pressed it can be printed 
				; dw Msg1,Msg2,Msg3,Msg4,Msg5,MsgEsc,MsgTab,MsgCaps,MsgQ,MsgW,MsgE,MsgR,MsgT,MsgF7,MsgF8,MsgF9
				; dw MsgA,MsgS,MsgD,MsgF,MsgG,MsgF4,MsgF5,MsgF6,MsgSh,MsgZ,MsgX,MsgC,MsgV,MsgF1,MsgF2,MsgF3
				; dw Msg0,Msg9,Msg8,Msg7,Msg6,MsgMinus,MsgPlus,MsgDel,MsgP,MsgO,MsgI,MsgU,MsgY,MsgEqu,MsgQuote,MsgF0
				; dw MsgEnter,MsgL,MsgK,MsgJ,MsgH,MsgSemi,MsgColon,MsgEdit,MsgSpace,MsgSym,MsgM,MsgN,MsgB,MsgComma,MsgFStop,MsgInv
				; dw MsgCtrl,MsgUp,MsgDown,MsgLeft,MsgRight
				
; Msg1:			dm "1"
				; db eof
; Msg2:			dm "2"
				; db eof
; Msg3:			dm "3"
				; db eof
; Msg4:			dm "4"
				; db eof
; Msg5:			dm "5"
				; db eof
; MsgEsc:			dm "ESCAPE"
				; db eof
; MsgTab:			dm "TAB"
				; db eof
; MsgCaps:		dm "CAPS"
				; db eof
; MsgQ:			dm "Q"
				; db eof
; MsgW:			dm "W"
				; db eof
; MsgE:			dm "E"
				; db eof
; MsgR:			dm "R"
				; db eof
; MsgT:			dm "T"
				; db eof
; MsgF7:			dm "F7"
				; db eof
; MsgF8:			dm "F8"
				; db eof
; MsgF9:			dm "F9"
				; db eof
				
; MsgA:			dm "A"
				; db eof
; MsgS:			dm "S"
				; db eof
; MsgD:			dm "D"
				; db eof
; MsgF:			dm "F"
				; db eof
; MsgG:			dm "G"
				; db eof
; MsgF4:			dm "F4"
				; db eof
; MsgF5:			dm "F5"
				; db eof
; MsgF6:			dm "F6"
				; db eof
; MsgSh:			dm "SHIFT"
				; db eof
; MsgZ:			dm "Z"
				; db eof
; MsgX:			dm "X"
				; db eof
; MsgC:			dm "C"
				; db eof
; MsgV:			dm "V"
				; db eof
; MsgF1:			dm "F1"
				; db eof
; MsgF2:			dm "F2"
				; db eof
; MsgF3:			dm "F3"
				; db eof
				
; Msg0:			dm "0"
				; db eof
; Msg9:			dm "9"
				; db eof
; Msg8:			dm "8"
				; db eof
; Msg7:			dm "7"
				; db eof
; Msg6:			dm "6"
				; db eof
; MsgMinus:		dm "-"
				; db eof
; MsgPlus:		dm "PLUS"
				; db eof
; MsgDel:			dm "DELETE"
				; db eof
; MsgP:			dm "P"
				; db eof
; MsgO:			dm "O"
				; db eof
; MsgI:			dm "I"
				; db eof
; MsgU:			dm "U"
				; db eof
; MsgY:			dm "Y"
				; db eof
; MsgEqu:			dm "EQUALS"
				; db eof
; MsgQuote:		db 34
				; db eof
; MsgF0:			dm "F0"
				; db eof
				
; MsgEnter:		dm "ENTER"
				; db eof
; MsgL:			dm "L"
				; db eof
; MsgK:			dm "K"
				; db eof
; MsgJ:			dm "J"
				; db eof
; MsgH:			dm "H"
				; db eof
; MsgSemi:		dm "SEMICOLON"
				; db eof
; MsgColon:		dm ":"
				; db eof
; MsgEdit:		dm "EDIT"
				; db eof
; MsgSpace:		dm "SPACE"
				; db eof
; MsgSym:			dm "SYMBOL"
				; db eof
; MsgM:			dm "M"
				; db eof
; MsgN:			dm "N"
				; db eof
; MsgB:			dm "B"
				; db eof
; MsgComma:		dm ","
				; db eof
; MsgFStop:		dm "."
				; db eof
; MsgInv:			dm "INV"
				; db eof
				
; MsgCtrl:		dm "CONTROL"
				; db eof
; MsgUp:			dm "UP"
				; db eof
; MsgDown:		dm "DOWN"
				; db eof
; MsgLeft:		dm "LEFT"
				; db eof
; MsgRight:		dm "RIGHT"
				; db eof
