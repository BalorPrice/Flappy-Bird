;-------------------------------------------------------
; SPRITE ANIMATION DATA

;-------------------------------------------------------
sprite.frames.page.os:			equ 0
sprite.frames.src.os:			equ 1
sprite.frames.width.os:			equ 3
sprite.frames.depth.os:			equ 4
sprite.frames.x_offset.os:		equ 5
sprite.frames.y_offset.os:		equ 6
sprite.frames.bgd_col.os:		equ 7
					
;-------------------------------------------------------
; FRAMES DATA

sprite.frames:
; Frames data contains address of frame in mainpage only, and address of right-scrolled version

sprite.frames.hero: equ 0
	@wings_level:	equ 0
				db GfxPage1
				dw gfx.bird1
				db 10,12,0,0,sky_blue * &11
	@wings_up: 	equ @-wings_level + 1
				db GfxPage1
				dw gfx.bird2
				db 10,12,0,0,sky_blue * &11
	@wings_down:equ @-wings_up + 1
				db GfxPage1
				dw gfx.bird3
				db 10,12,0,0,sky_blue * &11
	@bird_hit:	equ @-wings_down + 1
				db GfxPage1
				dw gfx.bird4
				db 10,12,0,0,sky_blue * &11
				
sprite.frames.pipe: 	equ @-bird_hit + 1
	@pipe_head:	equ @-bird_hit + 1
				db GfxPage1
				dw gfx.pipe.head
				db 14,14,0,0,sky_blue * &11
	@pipe_neck:	equ @-pipe_head + 1
				db GfxPage1
				dw gfx.pipe.neck
				db 14,1,0,0,sky_blue * &11
				
sprite.frames.extra:	equ @pipe_neck + 1
	@logo:		equ @pipe_neck + 1
				db GfxPage1
				dw gfx.logo
				db 50,22,0,0,sky_blue * &11
	@space:		equ @logo + 1
				db GfxPage1
				dw gfx.space
				db 16,14,0,0,sky_blue * &11
sprite.frames.clouds:	equ @space + 1
				db GfxPage1
				dw gfx.clouds
				db 30,10,0,0,sky_blue * &11
sprite.frames.scenery:	equ sprite.frames.clouds + 1
				db GfxPage1
				dw gfx.scenery
				db 21,28,0,0,sky_blue * &11
	@tap_flap:	equ sprite.frames.scenery + 1
				db GfxPage1
				dw gfx.tap_flap
				db 17,17,0,0,sky_blue * &11
sprite.frames.new: equ @-tap_flap + 1
				db GfxPage1
				dw gfx.new
				db 8,8,0,0,sky_blue * &11
				
sprite.frames.gover:equ sprite.frames.new + 1
				db GfxPage1
				dw gfx.game_over
				db 48,19,0,0,sky_blue * &11
				
sprite.frames.numbers:	equ sprite.frames.gover + 1
	@0:			equ sprite.frames.gover + 1
				db GfxPage1
				dw gfx.num.0
				db 4,10,0,0,sky_blue * &11	
	@1:			equ @0 +1
				db GfxPage1
				dw gfx.num.1
				db 4,10,0,0,sky_blue * &11	
	@2:			equ @1 +1
				db GfxPage1
				dw gfx.num.2
				db 4,10,0,0,sky_blue * &11	
	@3:			equ @2 +1
				db GfxPage1
				dw gfx.num.3
				db 4,10,0,0,sky_blue * &11
	@4:			equ @3 + 1
				db GfxPage1
				dw gfx.num.4
				db 4,10,0,0,sky_blue * &11	
	@5:			equ @4 +1
				db GfxPage1
				dw gfx.num.5
				db 4,10,0,0,sky_blue * &11	
	@6:			equ @5 +1
				db GfxPage1
				dw gfx.num.6
				db 4,10,0,0,sky_blue * &11	
	@7:			equ @6 +1
				db GfxPage1
				dw gfx.num.7
				db 4,10,0,0,sky_blue * &11
	@8:			equ @7 +1
				db GfxPage1
				dw gfx.num.8
				db 4,10,0,0,sky_blue * &11	
	@9:			equ @8 +1
				db GfxPage1
				dw gfx.num.9
				db 4,10,0,0,sky_blue * &11
				
;-------------------------------------------------------
; ANIMATION LISTS 

; Named animation offsets from sprite.animations
sprite.anim.hero.coast:	equ 1
sprite.anim.hero.flap:	equ 2
sprite.anim.hero.hit:	equ 3
sprite.anim.pipe.head:	equ 4
sprite.anim.pipe.neck:	equ 5
sprite.anim.logo:		equ 6
sprite.anim.space:		equ 7
sprite.anim.clouds:		equ 8
sprite.anim.scenery:	equ 9
sprite.anim.tap_flap:	equ 10
sprite.anim.new:		equ 11
sprite.anim.gover:		equ 12

sprite.anim.0:			equ 13
sprite.anim.1:			equ 14 
sprite.anim.2:			equ 15
sprite.anim.3:			equ 16
sprite.anim.4:			equ 17
sprite.anim.5:			equ 18
sprite.anim.6:			equ 19
sprite.anim.7:			equ 20
sprite.anim.8:			equ 21
sprite.anim.9:			equ 22


sprite.animations:
; Animation lists address table
				dw sprite.hero.coast, sprite.hero.flap, sprite.hero.hit, sprite.pipe.head, sprite.pipe.neck
				dw sprite.logo, sprite.space, sprite.clouds, sprite.scenery, sprite.tap_flap, sprite.new, sprite.gover
				dw sprite.0, sprite.1, sprite.2, sprite.3, sprite.4
				dw sprite.5, sprite.6, sprite.7, sprite.8, sprite.9
				
;-------------------------------------------------------
; ANIMATION DATA

; frame details address, count in 1/50s sec, y-offset to centre frame, + one more byte???

sprite.hero.coast:			db @wings_level,192, loop_anim
sprite.hero.flap:			db @wings_up,5, @wings_level,3, @wings_down,6, @wings_level,5, loop_anim
sprite.hero.hit:			db @bird_hit,4, @wings_level,192, loop_anim

sprite.pipe.head:			db @pipe_head,192, loop_anim
sprite.pipe.neck:			db @pipe_neck,192, loop_anim

sprite.logo:				db @logo,192, loop_anim
sprite.space:				db @space,192, loop_anim
sprite.clouds:				db sprite.frames.clouds,192, loop_anim
sprite.scenery:				db sprite.frames.scenery,192, loop_anim
sprite.tap_flap:			db @tap_flap,192, loop_anim
sprite.new:					db sprite.frames.new,192, loop_anim
sprite.gover:				db sprite.frames.gover,192, loop_anim

sprite.0:					db @0,192, loop_anim
sprite.1:					db @1,192, loop_anim
sprite.2:					db @2,192, loop_anim
sprite.3:					db @3,192, loop_anim
sprite.4:					db @4,192, loop_anim
sprite.5:					db @5,192, loop_anim
sprite.6:					db @6,192, loop_anim
sprite.7:					db @7,192, loop_anim
sprite.8:					db @8,192, loop_anim
sprite.9:					db @9,192, loop_anim

;-------------------------------------------------------
