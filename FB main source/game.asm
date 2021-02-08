;-------------------------------------------------------
; GAMEPLAY MODULE

;-------------------------------------------------------
game.attract.prep1:
; Set up logos as sprites for front end
				call attract.print_screen.set
				ld a,credits.mode.idle
				ld (credits.mode),a
				ld a,No
				ld (credits.on),a
	@set_state:
				ld de,game.attract.prep2
				ld (game.state + 1),de
				ret
				
;-------------------------------------------------------
game.attract.prep2:
	@check_screen_printed:
				ld a,(attract.print_screen.req)
				cp On
				ret z
				
				call attract.start_logo
				call pipe.init
				call scrolly.init
				
	@set_state:
				ld de,game.attract.run
				ld (game.state + 1),de
				ret

;-------------------------------------------------------
game.attract.run:
; Wait for space/fire to play
				call credits.check_sound
				call attract.logo_wobble.update			; Update logo height
				call grass.update
				call scrolly.update

	@check_credits:
				ld a,(keys.processed)
				bit Escape,a
				jr z,@+check_start

	@set_credits_mode:
				ld a,credits.mode.init
				ld (credits.mode),a
				ld a,Yes
				ld (credits.on),a
				ret
				
	@check_start:
				ld a,(keys.processed)
				bit Fire,a
				ret z
				
				ld a,credits.mode.play_game
				ld (credits.mode),a
				
	@play_click:
				ld c,sfx.click
				call sfx.setC.out
	@start_game:
				ld de,game.reset
				ld (game.state + 1),de
				ret

;-------------------------------------------------------
game.reset:
; Init new game
				call attract.kill_sprites				; Kill sprites used for attract sequence
				call attract.print_screen.set
				call hud.init							; Init scores as sprites
				call hero.init
				call collider.slot.init					; Reset any collider slots
				ld a,No
				ld (scrolly.on),a
				call hero.tap_flap.init					; Make 'tap to flap' sign 
				
	@update_state:
				ld de,game.run
				ld (game.state + 1),de
				ret
				
;-------------------------------------------------------
game.run:
; Main game state
				call credits.check_sound
				call attract.logo_wobble.update			; Used for hero's position when in get ready mode
				call hero.tap_flap.update				; Update prompt sign
				
				call hero.move							; Update hero position
				call pipe.spawn							; Spawn new pipe and colliders if ready
				call grass.update
				call collider.test_all					; Test all colliders against hero position, award points if necessary
				ld a,(hero.ok)
				cp Yes
				ret z									; Return Z if fine, else kill hero
				
	@set_dying:
				call hero.kill
				call pipe.move.set_off

	@update_state:
				ld de,game.dying
				ld (game.state + 1),de
				ret

;-------------------------------------------------------
game.dying:
; Collision found - continue while hero falls to ground
				call credits.check_sound
				call grass.update
				call hero.move.dead
				ret nz									; Z flag set if hero on ground
				
				call hero.floored
				call attract.gover.print
				ld hl,attract.gover.time
				ld (attract.gover.timer),hl
	@update_state:
				ld de,game.game_over
				ld (game.state + 1),de
				ret

;-------------------------------------------------------
game.game_over:
; Animate game over message
				call credits.check_sound
				call grass.update
				call hero.move.dead
				call attract.gover.move					; Bounce the game over sign
				call attract.gover.timer.update
				ret nz									; Scoreboard prints after a delay

	@clear_sprites:										; Set display to save screen with sprites on, then reset all sprites
				ld a,On
				ld (sprite.save_screen.on),a
	@update_state:
				ld de,game.scoreboard.init
				ld (game.state + 1),de
				ret

;-------------------------------------------------------
game.scoreboard.init:
	@check_reset:										; Check screen saved before proceeding
				ld a,(sprite.save_screen.on)
				cp Yes
				ret z

				call scoreboard.init.set
	@update_state:
				ld de,game.scoreboard.wait
				ld (game.state + 1),de
				ret
				
;-------------------------------------------------------
game.scoreboard.wait:
				call credits.check_sound
	@check_fire:
				ld a,(keys.processed)
				bit Fire,a
				ret z
	@play_click:
				ld c,sfx.click
				call sfx.setC.out				
	@update_state:
				ld de,game.attract.prep1
				ld (game.state + 1),de
				ret
				
;-------------------------------------------------------
game.prep_512k_only:
; If machine is missing 256K expansion, print an apology message
				call attract.print_screen.set
				call attract.start_logo.256
				call scrolly.init
				ld a,Off
				ld (music.on),a
				
	@update_state:
				ld de,game.run_512K_only
				ld (game.state + 1),de
				ret
				
;-------------------------------------------------------
game.run_512K_only:
				call attract.logo_wobble.update.256
				ret
				
;-------------------------------------------------------
