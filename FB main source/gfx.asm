;-------------------------------------------------------
; GRAPHICS DATA

;-------------------------------------------------------

gfx.src:
				dump GfxPage1,0
				org &8000
				
gfx.start:
	gfx.scroll_data.start:
				include "completed gfx/bird.asm"
				include "completed gfx/pipe.asm"
				include "completed gfx/numbers.asm"
				include "completed gfx/logo.asm"
				include "completed gfx/space.asm"
				include "completed gfx/clouds.asm"
				include "completed gfx/game over.asm"
				include "completed gfx/scenery.asm"
				include "completed gfx/tap to flap.asm"
				include "completed gfx/new.asm"
				include "completed gfx/buttons.asm"
	gfx.scroll_data.end:
	gfx.scroll_data.len:	equ gfx.scroll_data.end - gfx.scroll_data.start
	
	gfx.scroll_data.scrolled:
				ds gfx.scroll_data.len
gfx.end:
gfx.len:		equ gfx.end - gfx.start

				dump MainPage,gfx.src - &8000
				org gfx.src

;-------------------------------------------------------
