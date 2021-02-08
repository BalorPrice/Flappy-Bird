;-------------------------------------------------------
; DISPLAY

; State machine for display drivers.  See auto.asm:main.disp.loop
; NB game.asm module changes state of display driver.


sprite.save_screen.on: db Off

display.mod:
;-------------------------------------------------------
disp.game:
				call house.dbuf.swap
	@test_save_screen:
				ld a,(sprite.save_screen.on)			; If requested, save the screen with the sprites on, then delete sprites
				cp Off
				jp z,@+next
				call jump.save_screen
				ld a,Off
				ld (sprite.save_screen.on),a
				call sprite.slots.init_all
		@next:
				call sprite.replace_bgd_all
				call attract.print_screen
				call credits.update
				call pipe.move.stop						; Test if movement has stopped all sprites at once
				call sprite.update_all
				call grass.print
				call sprite.print_all
				call scrolly.update
				call scoreboard.init
				ret

;-------------------------------------------------------
