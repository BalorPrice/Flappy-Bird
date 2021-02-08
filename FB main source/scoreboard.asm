;-------------------------------------------------------
; SCOREBOARD

;-------------------------------------------------------
scoreboard.jokesLUT:
				dw @joke1,@joke2,@joke3,@joke4,@joke5,@joke6,@joke7,@joke8,@joke9,@joke10
				dw @joke11,@joke12,@joke13,@joke14,@joke15,@joke16,@joke17,@joke18,@joke19,@joke20
				dw @joke21,@joke22,@joke23,@joke24
				
@joke1:
				dm "      Out for a duck"
				db eof
@joke2:
				dm "  What are you, chicken?"
				db eof
@joke3:
				dm "   No jive turkeys here"
				db eof
@joke4:
				dm "       [Going cheep]"
				db eof
@joke5:
				dm "  Out of the flying pan"
				db eof
@joke6:
				dm "       [Dead winger]"
				db eof
@joke7:
				dm "  Shaking a tail feather"
				db eof
@joke8:
				dm "  Better luck nest time"
				db eof
@joke9:
				dm "   Owl always love you"
				db eof
@joke10:
				dm "    [Budgie smuggler]"
				db eof
@joke11:
				dm " Skill, or just good duck?"
				db eof
@joke12:
				dm "Gone the way of the Dodo"
				db eof
@joke13:
				dm "  Well, this is hawkward"
				db eof
@joke14:
				dm "You need a sparrowchute"
				db eof
@joke15:
				dm " Calculate your owlgebra"
				db eof
@joke16:
				dm "   [Lord of the Wings]"
				db eof
@joke17:
				dm "Call the vet for tweetment"
				db eof
@joke18:
				dm "  You took a right tern"
				db eof
@joke19:
				dm "  No worries, no egrets"
				db eof
@joke20:
				dm "    Did you quack up?"
				db eof
@joke21:
				dm "     No harm no fowl"
				db eof
@joke22:
				dm "    [Hendurance test]"
				db eof
@joke23:
				dm "       [Dead winger]"
				db eof
@joke24:
				dm "   [Lord of the Wings]"
				db eof
				
scoreboard.print_data:
				dw &8440 / 2, &40 - 1
				db orange * &11
				dw &4340 / 2, &40 - 1
				db white * &11
				dw &4844 / 2, &40 - 5
				db orange * &11
				dw &7f44 / 2, &40 - 5
				db white * &11
				dw &4340 / 2, &40 - 1
				db dark_grey * &11
				dw &8540 / 2, &40 - 1
				db dark_grey * &11
				dw &8640 / 2, &40 - 1
				db dark_grey * &11
				dw eof
				
scoreboard.score.data:
				db &52, &4c
				dm "SCORE"
				db eof
scoreboard.score.data2:
				db &52, &4d
				dm "SCORE"
				db eof
scoreboard.best.data:
				db &98, &4c
				dm "BEST"
				db eof
scoreboard.best.data2:
				db &98, &4d
				dm "BEST"
				db eof

scoreboard.score_cols:									; 16-byte colourise table for SCORE and BEST headings
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,orange
scoreboard.score_cols2:									; Another version to make bottom colours
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,white
				
scoreboard.joke_cols:
				db 0,0,0,0,0,0,0,0,0,0,pink,0,0,0,0,light_green
scoreboard.joke_cols2:
				db 0,0,0,0,0,0,0,0,0,0,dark_green,0,0,0,0,dark_green
				
scoreboard.new_best:	db No							; Flag for new best score

scoreboard.init.req:	db Off							; Flas for display to print scoreboard
scoreboard.rand:		db 0

;-------------------------------------------------------
scoreboard.init.set:
; Set flag for display loop to print scoreboard
				ld a,On
				ld (scoreboard.init.req),a
				ret
				
;-------------------------------------------------------
scoreboard.init:
; Print the scoreboard, set up the sprites for it
	@check_requested:
				ld a,(scoreboard.init.req)
				cp Off
				ret z
				
				call scoreboard.set_rand
				call scoreboard.set_best				
				call scoreboard.print_board
				call scoreboard.print_text
				call scoreboard.print_best
				call scoreboard.print_curr
				call house.dbuf.swap
				call scoreboard.print_board
				call scoreboard.print_text
				call scoreboard.print_best
				call scoreboard.print_curr
				call house.dbuf.swap
				call jump.save_screen
				
				ld a,Off
				ld (scoreboard.init.req),a
				ret
				
;-------------------------------------------------------
scoreboard.set_rand:
				ld a,(maths.seed)
				ld (scoreboard.rand),a
				ret
				
;-------------------------------------------------------
scoreboard.set_best:
				ld a,No									; Assume no new best
				ld hl,(hud.score.best)					; Test scores
				ld de,(hud.score)
				and a
				sbc hl,de
				jr nc,@+next
				ld hl,(hud.score)						; If new score bigger, copy into best 
				ld (hud.score.best),hl
				ld a,Yes								; Set flag
		@next:
				ld (scoreboard.new_best),a
				ret

;-------------------------------------------------------
scoreboard.print_best:
				ld ix,hud.score.best
				ld a,&a1
				call @print_scoreAIX
				ret

scoreboard.print_curr:
				ld ix,hud.score
				ld a,&5e
				call @print_scoreAIX
				ret
				
@print_scoreAIX:
				ld ( @+centre + 1),a
				call @+calc_overall_widthIX
	@calc_start_pos:									; Start position = &80 - (Total / 2)
				sra a
				neg
		@centre:add 0
				ld e,a
				ld d,0
				
	@set_dig_1:											; Set X pos for digit
				ld a,( ix )
				and &0f
				call nz,@update_tally
				add sprite.frames.numbers
				call @+print
		@add_dig_width:									; Calc position of next digit
				ld a,( ix )
				and &0f
				call @+add_widthADE		
	@set_dig_2:											; Repeat for next two digits
				ld a,( ix + 1)
				for 4,srl a
				or a
				call nz,@update_tally
				add sprite.frames.numbers
				call @+print
				
				ld a,( ix + 1)
				for 4,srl a
				call @+add_widthADE		
	@set_dig_3:			
				ld a,( ix + 1)
				and &0f
				call nz,@update_tally
				add sprite.frames.numbers
				dec d
				call @+print
				ret

@update_tally:
				dec d
				ret
				
@print:
				bit 7,d
				ret z
				push de
				push ix
				ld d,&59
				call jump.print_frame.maskADE
				pop ix
				pop de
				ret
				
				
@calc_overall_widthIX:
; Return width of printable characters
				ld d,0
				ld e,0
				ld a,( ix )
				and &0f
				call @+add_widthADE
				ld a,( ix + 1)
				for 4,srl a
				call @+add_widthADE
				ld a,( ix + 1)
				and &0f
				call @+add_widthADE
	@check_width:										; If score is zero, use default (width of one zero digit)
				ld a,e
				or a
				ret nz
				ld a,6
				ret

@add_widthADE:
; Add width of digit A to tally E.  If D=0, assume leading zeroes will be invisible and skip.
	@check_leading_zeroes:
				bit 7,d									; If previous digit is non-zero, count all numbers
				jr nz,@+skip
				or a									; Otherwise, check if this is a leading zero, quit if so
				ret z
				dec d									; Not a leading zero, set flag
		@skip:
				cp 1									; 1s are narrower than other digits
				jr z,@+width_1
	@width_norm:
				ld a,e
				add 6									; These are one pixel too small so digits overlap
				ld e,a
				ret
	@width_1:
				ld a,e
				add 4
				ld e,a
				ret
				
;-------------------------------------------------------
scoreboard.print_board:
				ld ix,scoreboard.print_data
	@print_main:				
				ld hl,&4440
				ld de,&84c0
				ld a,off_white * &11
				call scoreboard.print_byte_rectHLDEA
	@horiz_bevels:
				ld a,( ix + 0)
				and ( ix + 1)
				cp -1 
				jr z,@+vert_bevels
				call @+print_horiz_bevelIX
				ld bc,5
				add ix,bc
				jr @-horiz_bevels
@vert_bevels:
	@left_bevel:
				ld hl,&4944 / 2
				ld a,&40 - 10
				ld bc,&80
				ld e,orange * &10 + off_white
		@loop:
				ld (hl),e
				add hl,bc
				dec a
				jr nz,@-loop
				
	@right_bevel:
				ld hl,&49bb / 2
				ld a,&40 - 10
				ld bc,&80
				ld e,off_white * &10 + white
		@loop:
				ld (hl),e
				add hl,bc
				dec a
				jr nz,@-loop
				
	@outline:
				ld hl,&433e / 2
				ld d,&44
				ld bc,&80
				ld e,dark_grey
		@loop:
				ld a,(hl)
				and &f0
				or e
				ld (hl),a
				add hl,bc
				dec d
				jr nz,@-loop
				
				ld hl,&43c1 / 2
				ld d,&44
				ld bc,&80
				ld e,dark_grey * &10
		@loop:
				ld a,(hl)
				and &0f
				or e
				ld (hl),a
				add hl,bc
				dec d
				jr nz,@-loop
				ret
				
;-------------------------------------------------------
scoreboard.print_text:
@print_score_best2:										; Print SCORE and BEST shadow (white)
				ld hl,scoreboard.score_cols2
				call font.set_colourisedHL
				ld hl,scoreboard.score.data2
				call font.print_stringHL
				ld hl,scoreboard.best.data2
				call font.print_stringHL
@print_score_best1:										; Print SCORE and BEST in orange
				ld hl,scoreboard.score_cols
				call font.set_colourisedHL
				ld hl,scoreboard.score.data
				call font.print_stringHL
				ld hl,scoreboard.best.data
				call font.print_stringHL
@print_new_best:										; Print NEW icon if new best score achieved
				ld a,(scoreboard.new_best)
				cp No
				jr z,@+setup_joke
				ld a,sprite.frames.new
				ld de,&4c88
				call jump.print_frameADE

@setup_joke:											; Set new font colours for the joke
				ld hl,scoreboard.joke_cols2
				call font.set_colourisedHL
				ld de,&6f48
				call @+print_joke
				ld hl,scoreboard.joke_cols
				call font.set_colourisedHL
				ld de,&6e48
				call @+print_joke
				ret
				
@print_joke:
				push de
	@check_zero:										; If score is zero, use "out for a duck" message
				ld hl,hud.score
				ld a,(hl)
				inc hl
				or (hl)
				or a
				jr z,@+next
				
	@random:	
				ld a,(scoreboard.rand)
				ld b,24 - 1
				call maths.modAB
				inc a
	@next:
				add a
				ld c,a
				ld b,0
				ld hl,scoreboard.jokesLUT
				add hl,bc
				ld a,(hl)
				inc hl
				ld h,(hl)
				ld l,a
				pop de
				call font.print_stringHLDE
				ret
				
;-------------------------------------------------------
@print_horiz_bevelIX:
; Print a horizontal line from data at IX
				ld l,( ix + 0)							; Get screen address
				ld h,( ix + 1)
				ld c,( ix + 2)							; Get width in bytes
				ld b,( ix + 3)
				ld a,( ix + 4)							; Get colour
				
				ld (hl),a
				ld d,h
				ld e,l
				inc de
				ldir
				ret
				
;-------------------------------------------------------
scoreboard.print_byte_rectHLDEA:
; print a rectangle at coords (L,H) to (E,D) with colour A.  Byte accuracy only
				push af
	@get_depth_counter:
				ld a,d
				sub h
				ld b,a
	@get_dest_addr:
				srl h
				rr l
	@get_byte_dest:
				srl d
				rr e
	@get_width_counter:
				ld a,e
				sub l
				ld c,a

				pop af

	@y_loop:
				push bc
				push hl
	@x_loop:
				ld (hl),a
				inc l
				dec c
				jp nz,@-x_loop

				for 4,rrca

				pop hl
				ld de,128
				add hl,de

				pop bc
				djnz @-y_loop
				ret

;-------------------------------------------------------