;-------------------------------------------------------
; HOUSEKEEPING ROUTINES

; Paging
MainPage:		equ 1									; Main game logic here
MusicPage:		equ 3
GfxPage1:		equ 5
ScreenPage1:	equ 8  									; Double-buffered screen allocation
ScreenPage2:	equ 10
ScreenPage3:	equ 12									; Static background ccopy
GfxPage2:		equ 14

; Logic signalling - some equates to make code easier to read
Yes:			equ 0
No:				equ -1
Success:		equ 0
Failure:		equ -1
On:				equ 0
Off:			equ -1
True:			equ 0
False:			equ -1

eof:			equ -1									; General End Of Field token to end data strings

; Hardware values
LMPR:			equ 250
HMPR:			equ 251
VMPR:			equ 252
PaletteBaseReg:	equ 248
StatusReg:		equ 249
LineIntBit:		equ 0
FrameIntBit:	equ 3
KeyboardReg:	equ 254
BorderReg:		equ 254
HPEN:			equ 504
LPEN:			equ 248
ROMOut:			equ %00100000
Mode1:			equ 32 * 0
Mode2:			equ 32 * 1
Mode3:			equ 32 * 2
Mode4:			equ 32 * 3

; Palette management
curr_palette:	dw house.palette + 15

sky_blue:		equ 0
dark_green:		equ 1
mid_green:		equ 2
light_green:	equ 3
yellow:			equ 4
black:			equ 5
brown:			equ 6
pink:			equ 7
orange:			equ 8				; Very gently orange
grey:			equ 9
light_brown:	equ 10 
dark_grey:		equ 11
bright_orange:	equ 12
off_white:		equ 14
white:			equ 15

dark_grey_border: equ %00100000 + dark_grey
white_border:	equ %00100000 + white

;-------------------------------------------------------
house.set_paletteHL:
; Set current palette to HL but don't update outputted palette yet
				push bc
				ld bc,15
				add hl,bc
				ld (curr_palette),hl
				pop bc
				ret

house.set_curr_palette:
; Output current palette
				ld bc,&1000 + PaletteBaseReg
				ld hl,(curr_palette)
				otdr
				ret

house.palette:	db 117,12,74,101,102,78,2,39,98,120,36,8,46,0,126,127


house.restore_background_palette:
; Reset background colour to level 0
				ld a,99
				ld (house.palette + 8),a
				ret

house.palette_offA:
				ld bc,&1000 + PaletteBaseReg
	@loop:
				out (c),a
				djnz @-loop
				ret

;-------------------------------------------------------
house.clear_screensA:
; Clear both screens to colour A
				call house.clear_screenA
				ex af,af'
				call house.dbuf.swap
				ex af,af'
				call house.clear_screenA
				call house.dbuf.swap
				ret

house.clear_screenA:
; Clear one screen, slow version
				ld hl,0									; Mode 4 is 192 rows of 128 bytes, each with 2 nibbles for a pixel of colour info.
				ld de,1
				ld (hl),a								; Fill both nibbles with same colour
				ld bc,&6000 - 1
				ldir
				ret

;-------------------------------------------------------
house.dbuf.set:
; Set double buffer
	@set_low_page:
				ld a,screenPage1 + ROMOut				; 32=Turn ROM0 off, screen is in 0-24575
				out (LMPR),a
	@set_video_page:
				ld a,ScreenPage2 + Mode4				; 96=Mode 4, double-buffered screen system
				out (VMPR),a
				ret

house.dbuf.swap:
; Swap displayed and buffer screens
				in a,(LMPR)
				xor 2
				out (LMPR),a
				in a,(VMPR)
				xor 2
				out (VMPR),a
				ret

			if defined (DEBUG)
house.errorHL:
				di
				halt
			endif

;-------------------------------------------------------
house.wait_B_frames:
; Wait for B frames
	@loop:
				push bc
				call house.wait_frame
				; call keys.input
				pop bc
				djnz @-loop
				ret

;-------------------------------------------------------
house.wait_frame:
; Wait until frame interrupt occurred - this sets it to 50fps
				in a,(StatusReg)
				bit 3,a
				ret z
				jp house.wait_frame

house.wait_lineA:
				out (StatusReg),a
	@loop:
				in a,(StatusReg)
				bit 0,a
				ret z
				jp @-loop

;-------------------------------------------------------
house.dbuf.off:
			if defined (DEBUG)
				nop
			endif
house.dbuf.on:
; Toggle double buffering.  Labelled both ways for clarity of intent.
				in a,(VMPR)
				xor 2
				out (VMPR),a
				ret

;-------------------------------------------------------
house.error:
				xor a
	@loop:
				out (borderreg),a
				inc a
				jp @-loop
				
;-------------------------------------------------------