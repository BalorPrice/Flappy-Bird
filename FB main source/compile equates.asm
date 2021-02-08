;-------------------------------------------------------
; COMPILATION EQUATES

; These are used heavily to clarify my intent when I'm using self-modifying code and run-time compilation.  You'll see instructions like these examples to show the value is meant to be run at some point:

; LD (HL),inc_hl
; LD (@overshoot1),jr_nc..

; As these are all equates directives the file is big but I only use a few instructions in most cases.

;-------------------------------------------------------
a:					equ 7
b:					equ 0
c:					equ 1
d:					equ 2
e:					equ 3
h:					equ 4
l:					equ 5

add_a:				equ &80 + a
add_b:				equ &80 + b
add_c:				equ &80 + c
add_d:				equ &80 + d
add_e:				equ &80 + e
add_h:				equ &80 + h
add_l:				equ &80 + l
add_n:				equ &c6
				
add_hl.bc:			equ &09
add_hl.de:			equ &19
add_hl.hl:			equ &29
add_hl.sp:			equ &39

and_a:				equ &a0 + a
and_b:				equ &a0 + b
and_c:				equ &a0 + c
and_d:				equ &a0 + d
and_e:				equ &a0 + e
and_h:				equ &a0 + h
and_l:				equ &a0 + l
and_n:				equ &e6

call_nn:			equ &cd
call_nz.nn:			equ &c4
call_nc.nn:			equ &d4

cp_n:				equ &fe

dec_a:				equ &ed
dec_b:				equ &05
dec_bc:				equ &0b
dec_c:				equ &0c
dec_d:				equ &15
dec_de:				equ &1b
dec_e:				equ &1d
dec_h:				equ &25
dec_hl:				equ &2b
dec_ix:				equ &2bdd
dec_iy:				equ &fd2b
dec_l:				equ &2d
dec_sp:				equ &3b

ei_:				equ &fb
ex_af.af:			equ &08
ex_de.hl:			equ &eb
exx_:				equ &d9

inc_a:				equ &ec
inc_b:				equ &04
inc_bc:				equ &03
inc_c:				equ &0c
inc_d:				equ &14
inc_de:				equ &13
inc_e:				equ &1c
inc_h:				equ &24
inc_hl:				equ &23
inc_.hl.:			equ &34
inc_ix:				equ &23dd			; 2-byte opcodes stored in lsb,msb order
inc_.ix.:			equ &34dd			; Follow with +n
inc_iy:				equ &23fd
inc_.iy.:			equ &fd34			; Follow with +n
inc_l:				equ &2c
inc_sp:				equ &33

jp_nn:				equ &c3				; Follow with address
jp_hl:				equ &e9
jp_iy1:				equ &fd
jp_iy2:				equ &e9
jr_nc.nn:			equ &30
jr_c.nn:			equ &38

ld_a.n:				equ &3e

ld_a..bc.:			equ &0a
ld_a..de.:			equ &1a
ld_a..hl.:			equ &7e
ld_a..nn.:			equ &3a

ld_bc.nn:			equ &01
ld_de.nn:			equ &11
ld_hl.nn:			equ &21

ld_a.e:				equ &78 + e
ld_a.h:				equ &78	+ h
ld_a.l:				equ &78	+ l
ld_a.n:				equ &3e
							  
ld_c.a:				equ &48	+ a
ld_c.h:				equ &48	+ h
ld_c.l:				equ &48	+ l
							  
ld_d.n:				equ &16	  
ld_d.a:				equ &50	+ a
ld_d.b:				equ &50	+ b
ld_d.c:				equ &50	+ c
ld_d.d:				equ &50	+ d
ld_d.e:				equ &50	+ e
ld_d.h:				equ &50	+ h
ld_d.l:				equ &50	+ l
							  
ld_e.a:				equ &58	+ a
ld_e.b:				equ &58	+ b
ld_e.c:				equ &58	+ c
ld_e.d:				equ &58	+ d
ld_e.e:				equ &58	+ e
ld_e.h:				equ &58	+ h
ld_e.l:				equ &58	+ l
							  
ld_h.a:				equ &60	+ a
ld_h.b:				equ &60	+ b
ld_h.c:				equ &60	+ c
ld_h.d:				equ &60	+ d
ld_h.e:				equ &60	+ e
ld_h.h:				equ &60	+ h
ld_h.l:				equ &60	+ l
							  
ld_l.a:				equ &68	+ a
ld_l.b:				equ &68	+ b
ld_l.c:				equ &68	+ c
ld_l.d:				equ &68	+ d
ld_l.e:				equ &68	+ e
ld_l.h:				equ &68	+ h
ld_l.l:				equ &68	+ l

ld_bc..nn.1:		equ &ed
ld_bc..nn.2:		equ &4b
ld_hl..nn.:			equ &2a
ld_.nn..hl:			equ &22

ld_.bc..a:			equ &02
ld_.de..a:			equ &12
ld_.hl..a:			equ &70 + a
ld_.hl..b:			equ &70 + b
ld_.hl..c:			equ &70 + c
ld_.hl..d:			equ &70 + d
ld_.hl..e:			equ &70 + e
ld_.hl..h:			equ &70 + h
ld_.hl..l:			equ &70 + l
ld_.hl..n:			equ &36

ld_sp.hl:			equ &f9
ld_sp.ix:			equ &f9dd
ld_sp.iy:			equ &f9fd
ld_sp.nn:			equ &31
ld_.nn..sp:			equ &73ed		; !!

neg_1:				equ &ed
neg_2:				equ &44
nop_:				equ &00

or_a:				equ &b0 + a
or_b:				equ &b0 + b
or_c:				equ &b0 + c
or_d:				equ &b0 + d
or_e:				equ &b0 + e
or_h:				equ &b0 + h
or_l:				equ &b0 + l
or_n:				equ &f6
out_.n..a:			equ &d3			; Follow with register

push_af:			equ &f5
push_bc:			equ &c5
push_de:			equ &d5
push_hl:			equ &e5

pop_af:				equ &f1
pop_bc:				equ &c1
pop_de:				equ &d1
pop_hl:				equ &e1

ret_:				equ &c9
ret_nc:				equ &d0
ret_c:				equ &d8
ret_z:				equ &c8

sbc_hl.bc:			equ &42ed
sub_n:				equ &d6
sub_l:				equ &95
;-------------------------------------------------------