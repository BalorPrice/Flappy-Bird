;-------------------------------------------------------
; SFX DATA


;-------------------------------------------------------
; JUMP TABLE FOR A/D/S PART, and RELEASE PART
sfx.jump_table:
					dw 0,0
sfx.score_point:	equ 4								; Effect IDs go up in 4s for easy lookup in table
					dw sfx.score_point.dataADS, 0		; Address of Attack-Decay-Sustain data, Address of Release data
sfx.flap:			equ 8
					dw sfx.flap.dataADS, 0
sfx.click:			equ 12
					dw sfx.click.dataADS, 0
sfx.hit_pipe:		equ 16
					dw sfx.hit_pipe.dataADS, 0
sfx.hit_ground:		equ 20
					dw sfx.hit_ground.dataADS, 0

;-------------------------------------------------------
; Chromatic pitches, equal tempered
; C		21
; C#	3c
; D		55
; D#	6d
; E		84
; F		99
; F#	ad
; G		c0
; G#	d2
; A		e3
; A#	f3
; B		05

;-------------------------------------------------------
sfx.example.dataADS:
; Attack-Decay-Sustain data
				db %01000101							; Header format: retrigger, sound_en, noise_en, noise_type (2 bits each)
				db 0									; Pitch limiter (restrict the randomness of pitch)
				db &00,&00,&11							; Main data: octave, frequency, volume
				db &00,&00,&22
	@loop:
				db &00,&00,&44
				db sfx.loop
				dw @-loop								; Finish with loop instruction if release data is going to join the sound together
				; db sfx.end							; Else use end token.  For this, Release data will likely be 0.
sfx.example.dataR:
; Release data
				db %01000101,0
				db &03,&00,&33
				db &03,&00,&22
				db &03,&00,&11
				db sfx.end

;-------------------------------------------------------
sfx.score_point.dataADS:
; Add point to score
				db %00010000,%00000011
				db &06,&d2,&63							; g# oct 6
				db &05,&d2,&63
				db &05,&d2,&63
				db &05,&d2,&52
				db &05,&d2,&52

				db &07,&21,&63							; c oct 7
				db &06,&21,&63
				db &06,&21,&52
				db &06,&21,&53
				db &06,&21,&43
				db &06,&21,&42
				db &06,&21,&32
				db &06,&21,&31
				db &06,&21,&21
				db &06,&21,&21
				db &06,&21,&10
				db &06,&21,&10

				db sfx.end

;-------------------------------------------------------
sfx.flap.dataADS:
; flap noise
				db %00000111,0
				db &06,&c0,&33
				db &06,&e8,&54
				db &07,&20,&34
				db &07,&66,&11
				db sfx.end

;-------------------------------------------------------
sfx.click.dataADS:
; Attempt at speccy click to show button press
				db %00010100,0
				db &06,&e3,&55
				db &07,&e3,&30
				db sfx.end

;-------------------------------------------------------
sfx.hit_pipe.dataADS:
; Hit pipe and sail to the ground
				db %00010000,%00001111
				db &04,&6d,&99
				db &04,&4f,&88
				db &04,&31,&77
				db &04,&13,&77
				db &04,&f5,&66
				db &03,&f5,&66
				db &03,&d7,&55
				db &03,&b9,&55
				db &03,&9b,&55
				db &03,&7d,&44
				db &03,&5f,&44
				db &03,&41,&44
				db &03,&23,&33
				db &03,&05,&33
				db &02,&e7,&22
				db &02,&c9,&22
				db &02,&ab,&11
				db &02,&8d,&11
				db sfx.end

;-------------------------------------------------------
sfx.hit_ground.dataADS:
; Hit pipe and sail to the ground
				db %00010111,%00001111
				db &02,&23,&66
				db &02,&05,&55
				db &01,&e7,&44
				db &01,&c9,&33
				db &01,&ab,&22
				db &01,&8d,&11
				db sfx.end

;=======================================================