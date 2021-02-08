;-------------------------------------------------------
; SPRITES

sprite.mod:
;-------------------------------------------------------
; ANIMATION / FRAME DATA

				include "anim_data.asm"
				include "sprite_printers.asm"			; Sprite printing routines 

;-------------------------------------------------------
Set_x:			equ -2									; Set_pos equates for setting destination positions (use On to set both)
Set_y:			equ -3
Set_rel:		equ -4									; Set relative position to 
Set_xrel:		equ -5
Set_yrel:		equ -6

sprite.anim.null:			equ -1
loop_anim:					equ -2						; Used to loop rather than just stop animation

sprite.reset.on:			db No						; If set to Yes, reset all sprites on next update event.

;-------------------------------------------------------
; SPRITE SLOT DATA STRUCTURE

; Each sprite is allocated a 'slot' in memory, and treated as a linked list.
; Data structure for each sprite slot.  Access with an index register

sprite.anim.os:				equ 0						; Animation currently being displayed, listed in sprite.animations (anim data.asm)
sprite.anim.pos.os: 		equ 1						; Address of next datum in animation list
sprite.start.anim.pos.os: 	equ 3						; Address of start of animation data
sprite.delay.os: 			equ 5						; Current amount of frames before next frame is displayed (in 1/50ths second)

sprite.spd.xL.os:			equ 6						; X-speed in 8.8 format (-ve numbers accepted too)
sprite.spd.xH.os:			equ 7
sprite.spd.yL.os:			equ 8						; Y-speed in 8.8 format
sprite.spd.yH.os:			equ 9

sprite.xL.os:				equ 10						; Current x-position in 16.8 format, sub-pixel accuracy (low)
sprite.xH.os:				equ 11						; pixels, (high)
sprite.xB.os:				equ 12						; screens, (big)
sprite.yL.os:				equ 13						; Current y-position
sprite.yH.os:				equ 14
sprite.yB.os:				equ 15
sprite.frame.os:			equ 16						; Current frame number, data in sprite.frames
sprite.frame.width.os:		equ 17						; Width of current frame in bytes
sprite.frame.depth.os:		equ 18						; Depth of current frame in pixels
sprite.x_offset.os:			equ 19						;
sprite.y_offset.os: 		equ 20						; Y-offset in pixels to centre this frame
sprite.frame.page.os:		equ 21
sprite.frame.src.os:		equ 22

sprite.xL2.os:				equ 24						; Previous frame data - x-position
sprite.xH2.os:				equ 25
sprite.xB2.os:				equ 26
sprite.yL2.os:				equ 27						; y-position
sprite.yH2.os:				equ 28
sprite.yB2.os:				equ 29
sprite.frame2.os:			equ 30						; Frame number
sprite.frame2.width.os:		equ 31						; Frame width
sprite.frame2.depth.os: 	equ 32						; Frame depth
sprite.x_offset2.os:		equ 33
sprite.y_offset2.os:		equ 34						; Frame y-offset
sprite.frame2.page.os:		equ 35
sprite.frame2.src.os:		equ 36

sprite.dest.on.os:			equ 38						; Set On to stop movement at destination coords
sprite.dest.xL.os:			equ 39						; Destination coords
sprite.dest.xH.os:			equ 40
sprite.dest.xB.os:			equ 41
sprite.dest.yL.os:			equ 42
sprite.dest.yH.os:			equ 43
sprite.dest.yB.os:			equ 44
sprite.dest.set.os:			equ 45						; Set On to force sprite to move to destination on next update
sprite.rel.obj.os:			equ 46						; Base address of related object

sprite.prev.os:				equ 48						; Address of previous sprite in list
sprite.next.os:				equ 50						; Address of next sprite in list, will appear on top of current sprite if overlapping

sprite.birth.os:			equ 52						; If !=0, amount of frames until sprite history holds meaningful data
sprite.death.os:			equ 53						; If !=0, amount of frames until sprite is destroyed
sprite.die_visible.os:		equ 54						; If On, when dying, sprite will remain on screen after killed
sprite.invisible.os:		equ 55						; Set On for an invisible sprite (everything else updates)

sprite.print_rout.os:		equ 56						; Address of print routine
sprite.update_rout.os:		equ 58						; Address of update routine.  If 0, not active
sprite.clear_rout.os:		equ 60						; Address of clearing routine
sprite.object.os:			equ 62						; Address of associated object.  If 0, not linked
sprite.camera.os:			equ 64						; Address of associated camera object.  If 0, use 
sprite.collider.addr.os:	equ 66						; Address of collider attached to this sprite

sprite.frame_data.len:		equ sprite.xL2.os - sprite.xL.os	; Length of data to age for each display frame

;-------------------------------------------------------
; SPRITE SLOTS

sprite.slot.len:		equ sprite.collider.addr.os + 2			; Length of each slot
sprite.slot.max:		equ &30									; Total slots available
sprite.slot.data:		equ auto.end							; Start of free space.  !! This will be hard to find later.
sprite.slot.data.len: 	equ sprite.slot.len * sprite.slot.max	; Allocated memory found a
sprite.ll.count:		db 0									; Current total slots used in linked list
sprite.ll.first:		dw 0 									; Address of first node in list
sprite.ll.final:		dw 0									; Address of final node in list

;=======================================================
; SPRITE SLOT MANAGEMENT

;-------------------------------------------------------
sprite.slots.init_all:
; Clear all current sprite data
				xor a
				ld (sprite.ll.count),a
				ld hl,-1
				ld (sprite.ll.first),hl
				ld (sprite.ll.final),hl

				ld hl,sprite.slot.data
				ld de,sprite.slot.data + 1
				ld bc,sprite.slot.max * sprite.slot.len - 1
				ld (hl),&00
				ldir
				
				ld a,No
				ld (sprite.reset.on),a
				ret

;-------------------------------------------------------
sprite.slot.clearIX:
; Reset sprite slot at IX
				ld a,ixl
				ld l,a
				ld e,a
				ld a,ixh
				ld h,a
				ld d,a
				inc de
				ld bc,sprite.slot.len - 1
				ld (hl),0
				ldir
				ld ( ix + sprite.dest.on.os),Off		; Turn off destination coord checking
				ret

;-------------------------------------------------------
sprite.slot.clearHL:
; Reset sprite slot at HL
				push hl

				ld e,l
				ld d,h
				inc de
				ld bc,sprite.slot.len - 1
				ld (hl),0
				ldir

				pop hl

	@turn_off_dest_check:								; Turn off destination coord checking
				ld bc,sprite.dest.on.os
				add hl,bc
				ld (hl),Off
				ret

;-------------------------------------------------------
sprite.slot.find_new:
; Return HL => address of free sprite slot.  Return Z for success, NZ for failure
				ld hl,sprite.slot.data
				ld de,sprite.slot.len
				xor a
				ld b,sprite.slot.max
	@loop:
				cp (hl)
				ret z
				add hl,de
				djnz @-loop
	@return_failure:
				cp 1									; If not found, return NZ
				ret

;-------------------------------------------------------


;=======================================================
; LINKED LIST ROUTINES

;-------------------------------------------------------
sprite.ll.append:
; Append new sprite to end of current linked list.  Return with pointer in HL
			; if defined (DEBUG)
				; ld ( @+error_msg + 1),hl				; Save error message 
			; endif
			
				ld a,(sprite.ll.count)
				or a
				jp z,@+add_first
@append:
				ld ix,(sprite.ll.final)
				call sprite.ll.insert_afterIX
				; jr z,@+trap_error						; Fail if returned with Zero flag set

				ld a,l
				ld ixl,a
				ld a,h
				ld ixh,a
				ret										; Return NZ if successful

@add_first:												; Add first node to list
				ld ix,sprite.slot.data					; Use first slot
				ld hl,sprite.slot.data
				call sprite.slot.clearHL
	@set_birth_and_death:
				ld ( ix + sprite.birth.os),2
				ld ( ix + sprite.death.os),0
				ld ( ix + sprite.invisible.os),On		; Create as invidible by default
				ld ( ix + sprite.die_visible.os),Off	; Also remove sprite when dead (can leave on screen if necessary)
				ld ( ix + sprite.anim.os),sprite.anim.null
	@init_next_and_prev_nodes:							; Null pointers for head and tail
				ld hl,-1
				ld ( ix + sprite.next.os),l
				ld ( ix + sprite.next.os + 1),h
				ld ( ix + sprite.prev.os),l
				ld ( ix + sprite.prev.os + 1),h
	@set_obj_count:
				ld a,1
				ld (sprite.ll.count),a
	@set_ll_head:
				ld (sprite.ll.first),ix
				ld (sprite.ll.final),ix

				push ix
				pop hl
	@return_success:
				ld a,1
				or a									; Return NZ for success (A already non-zero)
				ret

@trap_error:
			; if defined (DEBUG)
	; @error_msg:	ld hl,0
				; jp house.errorHL
			; endif
				halt
				ld bc,1234
				ret
				
;-------------------------------------------------------
sprite.ll.insert_afterIX:
; Insert new sprite after IX in linked list, return with address in HL
	@test_objects:
				ld hl,0									; If HL=0 then failure
				ld a,(sprite.ll.count)
				cp sprite.slot.max
				ret z

				push iy
	@check_final:										; If inserting at end of list, correct final entry
				ld a,ixl
				ld l,a
				ld a,ixh
				ld h,a
				ld de,(sprite.ll.final)
				and a
				sbc hl,de
				push af									; Store Z if inserting after final node
	
	@inc_node_count:
				ld hl,sprite.ll.count
				inc (hl)
	@get_slot:											; Get address of new sprite object slot in HL
				call sprite.slot.find_new
				ld a,h									; Retrieve new node in IY
				ld iyh,a
				ld a,l
				ld iyl,a
	@clear_slot:										; Clear any previous object data
				call sprite.slot.clearHL
	@set_birth_death:									; Set birth and death counts on new node
				ld ( iy + sprite.birth.os),2
				ld ( iy + sprite.death.os),0
				ld ( iy + sprite.invisible.os),On
				ld ( iy + sprite.die_visible.os),Off
				ld ( iy + sprite.anim.os),sprite.anim.null
@set_pointers:
	@set_new.next_node:									; Set new.next address
				ld e,( ix + sprite.next.os)
				ld d,( ix + sprite.next.os + 1)
				ld ( iy + sprite.next.os),e
				ld ( iy + sprite.next.os + 1),d
	@set_new.prev_node:									; Set new.prev
				ld e,ixl
				ld d,ixh
				ld ( iy + sprite.prev.os),e
				ld ( iy + sprite.prev.os + 1),d
	@find_next_node:
				ld c,( ix + sprite.next.os)
				ld b,( ix + sprite.next.os + 1)
	@set_curr.next_node:								; Set next address in current node
				ld e,iyl
				ld d,iyh
				ld ( ix + sprite.next.os),e
				ld ( ix + sprite.next.os + 1),d
	@set_next.prev_node:
				ld a,b									; Skip if this is the final node
				or c
				cp -1
				jr z,@+skip
				ld ixl,c
				ld ixh,b
				ld ( ix + sprite.prev.os),e
				ld ( ix + sprite.prev.os + 1),d
		@skip:
				ex de,hl								; Return with address in HL
				pop af
				jp nz,@+skip
				ld (sprite.ll.final),hl
		@skip:
				pop iy
				ld a,1
				or a									; Return NZ for success
				ret

;-------------------------------------------------------
sprite.ll.insert_beforeIX:
	@test_objects:
				ld hl,0									; If HL=0 then failure
				ld a,(sprite.ll.count)
				cp sprite.slot.max
				ret z

				push iy
	@check_first:										; If inserting at beginning of list, correct first entry
				ld a,ixl
				ld l,a
				ld a,ixh
				ld h,a
				ld de,(sprite.ll.first)
				and a
				sbc hl,de
				push af									; Store Z flag if inserting at beginning of list
	
	@inc_node_count:
				ld hl,sprite.ll.count
				inc (hl)
	@get_slot:											; Get address of new sprite object slot in HL
				call sprite.slot.find_new
				ld a,h									; Copy node to IY
				ld iyh,a
				ld a,l
				ld iyl,a
	@clear_slot:										; Clear any previous object data
				call sprite.slot.clearHL
	@set_birth_death:									; Set birth and death counts on new node
				ld ( iy + sprite.birth.os),2
				ld ( iy + sprite.death.os),0
				ld ( iy + sprite.invisible.os),On
				ld ( iy + sprite.die_visible.os),Off
				ld ( iy + sprite.anim.os),sprite.anim.null
@set_pointers:											; Set new node's prev and current links, and reciprocal links within those nodes
	@set_new.prev_node:
				ld c,( ix + sprite.prev.os)				; Get previous from current node
				ld b,( ix + sprite.prev.os + 1)
				ld ( iy + sprite.prev.os),c				; Put in new node
				ld ( iy + sprite.prev.os + 1),b
	@set_new.next_node:
				ld e,ixl								; Set initial node's next to new node
				ld d,ixh
				ld ( iy + sprite.next.os),e
				ld ( iy + sprite.next.os + 1),d
	@set_curr.prev_node:
				ld e,iyl								; Get new node address
				ld d,iyh
				ld ( ix + sprite.prev.os),e				; Store in current.prev 
				ld ( ix + sprite.prev.os + 1),d
	@set_prev.next_node:
				ld a,b									; Skip if current is first node
				or c
				cp -1
				jr z,@+skip
				ld ixl,c								; Set IX to previous
				ld ixh,b
				ld ( ix + sprite.next.os),e				; Assign prev.next to new node
				ld ( ix + sprite.next.os + 1),d
		@skip:
				
				ex de,hl								; Return with address in HL and IX
				ld a,l
				ld ixl,a
				ld a,h
				ld ixh,a
				
				pop af									; Retrieve Z flag set if first object in linked list
				jr nz,@+skip
				ld (sprite.ll.first),hl
		@skip:
				pop iy
				ld a,1
				or a									; Return NZ for success
				ret

;-------------------------------------------------------
sprite.ll.deleteIX:
; Delete sprite node at IX.
	@dec_node_count:									; Reduce count
				ld hl,sprite.ll.count
				dec (hl)
				jr nz,@+get_nodes
	@set_no_nodes:										; If no nodes left, reset all pointers
				ld hl,0
				ld (sprite.ll.first),hl
				ld (sprite.ll.final),hl
				ld de,-1
				jp @+erase_node

	@get_nodes:											; Get pointers to next and previous nodes, to join these together
				ld e,( ix + sprite.next.os)
				ld d,( ix + sprite.next.os + 1)
				ld c,( ix + sprite.prev.os)
				ld b,( ix + sprite.prev.os + 1)
	@set_previous:
				ld a,c									; Skip setting previous node if this is the first node
				and b
				cp -1
				jr z,@+set_first_node
				ld iyl,c								; Find previous node and set prev.next address
				ld iyh,b
				ld ( iy + sprite.next.os),e
				ld ( iy + sprite.next.os + 1),d
				jr @+set_next
		@set_first_node:
				ld (sprite.ll.first),de

	@set_next:											; Test next node, skip setting if last in the list
				ld a,e
				and d
				cp -1
				jr z,@+set_final_node
				ld iyl,e								; Find next node, set next.prev address
				ld iyh,d
				ld ( iy + sprite.prev.os),c
				ld ( iy + sprite.prev.os + 1),b
				jr @+erase_node
		@set_final_node:
				ld (sprite.ll.final),bc

	@erase_node:
				push de
				call sprite.slot.clearIX				; Clear this node
				pop de									; Return next node address
				ret

;-------------------------------------------------------
sprite.ll.goto_nextIX:
; Go to next node from IX
	@check_final_node:									; Check if this is the final node
				ld a,( ix + sprite.next.os)
				and ( ix + sprite.next.os + 1)
				cp -1
				ret z									; Return if so

	@return_next_sprite:								; Reassign IX to next node
				ld e,( ix + sprite.next.os)
				ld d,( ix + sprite.next.os + 1)
				ld ixl,e
				ld ixh,d
	@return_success:
				xor a
				cp 1
				ret

;-------------------------------------------------------
sprite.ll.goto_previousIX:
; Go to previous node from IX
	@check_final_node:									; Check if this is the first node
				ld a,( ix + sprite.prev.os)
				and ( ix + sprite.prev.os + 1)
				cp -1
				ret z									; Return if so

	@return_prev_sprite:								; Reassign IX to previous node
				ld e,( ix + sprite.prev.os)
				ld d,( ix + sprite.prev.os + 1)
				ld ixl,e
				ld ixh,d
	@return_success:
				xor a
				cp 1
				ret

;-------------------------------------------------------

;=======================================================

;-------------------------------------------------------
sprite.set_routsIXHLDEBC:
; Set print rout to HL, DE to update rout, clear rout to BC
				push ix
				exx
				ld bc,sprite.print_rout.os
				add ix,bc
				exx
				ld ( @+print + 1),ix
	@print:		ld (0),hl								; Addresses must be stored atomically, so interrupts don't access this halfway through
				for 2,inc ix
				ld ( @+update + 2),ix
	@update:	ld (0),de
				for 2,inc ix
				ld ( @+clear + 2),ix
	@clear:		ld (0),bc
				pop ix
				
				ret

sprite.set_update_routIXHL:
; Set HL to update rout for sprite at IX
				push ix
				push bc
				ld bc,sprite.update_rout.os
				add ix,bc
				ld ( @+update + 1),ix
	@update:	ld (0),hl
				pop bc
				pop ix
				ret

; sprite.set_cameraIXHL:								; Not needed in this build
; Set sprite at IX to use camera sprite at HL
				; ld ( ix + sprite.update_rout.os),l
				; ld ( ix + sprite.update_rout.os + 1),h
				ret

;-------------------------------------------------------
sprite.set_posIXHLDE:
; Set new position of sprite (D.E, H.L), where D=yB and H=xB.  Position changed next update to destination coords.
				ld ( ix + sprite.dest.xH.os),l
				ld ( ix + sprite.dest.xB.os),h
				ld ( ix + sprite.dest.yH.os),e
				ld ( ix + sprite.dest.yB.os),d
				ld ( ix + sprite.dest.set.os),On		; Set flag to jump to this position next update
				ret

sprite.set_xposIXHL:
; Set new X position of sprite (H.L), where H=xB. 
				ld ( ix + sprite.dest.xH.os),l
				ld ( ix + sprite.dest.xB.os),h
				ld ( ix + sprite.dest.set.os),Set_X
				ret

sprite.set_xposIYHL:
				ld ( iy + sprite.dest.xH.os),l
				ld ( iy + sprite.dest.xB.os),h
				ld ( iy + sprite.dest.set.os),Set_X
				ret
				
sprite.set_yposIXHL:
; Set new Y position of sprite (H.L), where H=xB.
				ld ( ix + sprite.dest.yH.os),l
				ld ( ix + sprite.dest.yB.os),h
				ld ( ix + sprite.dest.set.os),Set_Y
				ret

sprite.set_yposIYHL:
				ld ( iy + sprite.dest.yH.os),l
				ld ( iy + sprite.dest.yB.os),h
				ld ( iy + sprite.dest.set.os),Set_Y
				ret

;-------------------------------------------------------
sprite.set_rel_posIXIYHLDE:
; Set relative position of sprite (D.E, H.L), where D=yB and H=xB.  Coords to be added to current position of sprite at IY
; Position changed next update to destination coords.
				ld ( ix + sprite.dest.xH.os),l
				ld ( ix + sprite.dest.xB.os),h
				ld ( ix + sprite.dest.yH.os),e
				ld ( ix + sprite.dest.yB.os),d
				ld a,iyl
				ld ( ix + sprite.rel.obj.os),a
				ld a,iyh
				ld ( ix + sprite.rel.obj.os + 1),a
				ld ( ix + sprite.dest.set.os),Set_rel
				ret

sprite.set_rel_xposIXIYHL:
				ld ( ix + sprite.dest.xH.os),l
				ld ( ix + sprite.dest.xB.os),h
				ld a,iyl
				ld ( ix + sprite.rel.obj.os),a
				ld a,iyh
				ld ( ix + sprite.rel.obj.os + 1),a
				ld ( ix + sprite.dest.set.os),Set_xrel
				ret

sprite.set_rel_yposIXIYHL:
				ld ( ix + sprite.dest.yH.os),l
				ld ( ix + sprite.dest.yB.os),h
				ld a,iyl
				ld ( ix + sprite.rel.obj.os),a
				ld a,iyh
				ld ( ix + sprite.rel.obj.os + 1),a
				ld ( ix + sprite.dest.set.os),Set_yrel
				ret
				
;-------------------------------------------------------
sprite.set_dest_posIXHLDE:
; Set end position of moving sprite IX to (D.E, H.L), where D=yB and H=xB.
				ld ( ix + sprite.dest.xH.os),l
				ld ( ix + sprite.dest.xB.os),h
				ld ( ix + sprite.dest.yH.os),e
				ld ( ix + sprite.dest.yB.os),d
				ld ( ix + sprite.dest.on.os),On			; Set flag to stop when sprite arrives at this position
				ret

;-------------------------------------------------------
sprite.set_speedIXHLDE:
; Set sprite speed of IX to (D.E, H.L)
				ld ( ix + sprite.spd.xL.os),l
				ld ( ix + sprite.spd.xH.os),h
				ld ( ix + sprite.spd.yL.os),e
				ld ( ix + sprite.spd.yH.os),d
				ret

sprite.set_xspeedIXHL:
; Set sprite X speed of IX to H.L.  Y speed unaffected
				ld ( ix + sprite.spd.xL.os),l
				ld ( ix + sprite.spd.xH.os),h
				ret
				
sprite.set_yspeedIXHL:
; Set sprite Y speed of IX to H.L.  X speed unaffected
				ld ( ix + sprite.spd.yL.os),l
				ld ( ix + sprite.spd.yH.os),h
				ret
				
;-------------------------------------------------------
sprite.set_animAIX:
; Set sprite at IX to new animation A.  0 is reserved for no sprite
			if defined (DEBUG)
	@check_anim:										; ! If anim 0 set, ignore it for now
				or a
				; ret z
				jp nz,@+skip
		@wait:
				jr @-wait
				ret
		@skip:
			endif

	@store_anim:										; Store anim number at end to enable printing of this sprite
				ld ( ix + sprite.anim.os),a
	@find_anim_data:									; Get start of anim data
				dec a
				ld l,a
				ld h,0
				add hl,hl
				ld de,sprite.animations
				add hl,de
				ld a,(hl)
				inc hl
				ld h,(hl)
				ld l,a
	@store_current_anim_pos:
				ld ( ix + sprite.anim.pos.os),l
				ld ( ix + sprite.anim.pos.os + 1),h
	@store_loop_position:								; Keep a copy of start of anim data for looping
				ld ( ix + sprite.start.anim.pos.os),l
				ld ( ix + sprite.start.anim.pos.os + 1),h

				call sprite.get_frame_dataIXHL			; Get data for frame, delay, width, depth, x and y offsets

				ld a,1									; Return NZ for success
				or a
				ret

;-------------------------------------------------------
sprite.set_anim.nullIX:
; Set sprite not to have an animation, but still be processed.  Useful for invisible objects.
				ld ( ix + sprite.anim.os),sprite.anim.null
				ret
				
;-------------------------------------------------------
sprite.killIX:
; Set sprite at IX to be removed
	@check_not_dying:									; Return if already set to dying
				ld a,( ix + sprite.death.os)
				or a
				ret nz
				ld ( ix + sprite.death.os),2			; Set frames to die for 
				ret

;-------------------------------------------------------
sprite.kill_all:
; Remove all sprites.
				ld a,(sprite.ll.count)
				or a
				ret z
				
				ld ix,(sprite.ll.first)
	@loop:
				call sprite.killIX
	@next_node:
				call sprite.ll.goto_nextIX
				jr nz,@-loop
				ret
				
;-------------------------------------------------------
sprite.update_all:
; Update sprite variables in linked list
@check_sprite_list:										; Ignore if no sprites to process
				ld a,(sprite.ll.count)
				or a
				ret z
				
				ld ix,(sprite.ll.first)
				push iy
@update_loop:
				call sprite.ageIX

	@get_time_elapsed:									; get amount of screen frames elapsed
				ld a,(int.new_frames_elapsed)
				or a
				jp z,@+update_birth_death				; If no frames elapsed, don't move at all

	@check_set_pos:										; If forced position change, set from dest coords
				ld a,( ix + sprite.dest.set.os)
				cp Off
				call nz,sprite.set_posA

@move:
	@check_dying:										; Don't update sprite movement if dying (will mostly be invisible anyway)
				xor a
				cp ( ix + sprite.death.os)
				jp nz,@+update_birth_death

	@update_x:
				ld a,(int.new_frames_elapsed)			; Update x position based on amount of frames elapsed
				ld b,a
				ld l,( ix + sprite.xL.os)
				ld h,( ix + sprite.xH.os)
				ld a,( ix + sprite.xB.os)
				ld e,( ix + sprite.spd.xL.os)
				ld d,( ix + sprite.spd.xH.os)

		@test_dir:										; Test MSB of xB to get x-direction
				bit 7,d
				jr nz,@+left_loop

		@right_loop:
				add hl,de
				jr nc,@+skip
				inc a
			@skip:
				djnz @-right_loop
				jp @+store_x

		@left_loop:
				add hl,de
				jr c,@+skip
				dec a
			@skip:
				djnz @-left_loop

		@store_x:
				ld ( ix + sprite.xL.os),l
				ld ( ix + sprite.xH.os),h
				ld ( ix + sprite.xB.os),a

	@update_y:
				ld a,(int.new_frames_elapsed)
				ld b,a
				ld l,( ix + sprite.yL.os)
				ld h,( ix + sprite.yH.os)
				ld a,( ix + sprite.yB.os)
				ld e,( ix + sprite.spd.yL.os)
				ld d,( ix + sprite.spd.yH.os)
		@test_dir:
				bit 7,d
				jr nz,@+up_loop

		@down_loop:
				add hl,de
				jr nc,@+skip
				inc a
			@skip:
				djnz @-down_loop
				jp @+store_y

		@up_loop:
				add hl,de
				jr c,@+skip
				dec a
			@skip:
				djnz @-up_loop

		@store_y:
				ld ( ix + sprite.yL.os),l
				ld ( ix + sprite.yH.os),h
				ld ( ix + sprite.yB.os),a

	@check_dest_on:
				ld a,( ix + sprite.dest.on.os)			; If destination coords turned on, check position.
				cp On
				call z,sprite.check_dest				; Check if sprite is at destination.  ! Hacky, movement is 4-way only

@update_birth_death:									; If sprite newly created or about to be destroyed, update these counters
				xor a
				cp ( ix + sprite.birth.os)
				jr z,@+skip
				dec ( ix + sprite.birth.os)
		@skip:
				cp ( ix + sprite.death.os)
				jr z,@+check_delay
				dec ( ix + sprite.death.os)
				jr nz,@+check_delay
				call sprite.ll.deleteIX					; If death count completed, then remove this node entirely
		@next_node:
				ld a,e
				or d
				cp -1
				jp z,@+end
				ld ixl,e								; Recover next node from delete routine
				ld ixh,d
				jp @-update_loop


	@check_delay:										; Check frames elapsed again
				ld a,(int.new_frames_elapsed)
				or a
				jr z,@+user_defined_update
				ld b,a

		@update_delay:									; Update count to next frame
				xor a
				cp ( ix + sprite.delay.os)
				jr z,@+new_frame
			@no_new_frame:								; Count not zero, just update and return
				dec ( ix + sprite.delay.os)				; !!  This should be smarter based on the amount of frames elapsed
				jr @+next_loop

		@new_frame:	
				ld a,sprite.anim.null					; If animation is null, don't process 
				cp ( ix + sprite.anim.os)
				jp z,@+next_loop
				push bc
				call sprite.update_frameIX				; Count is zero, collect new frame from animation data
				call sprite.get_frame_dataIXHL
				pop bc
		@next_loop:
				djnz @-update_delay

	@check_active:										; Check if sprites have been turned off while running
				ld a,(int.sprites.on)
				cp Off
				jr z,@+end
				
	@user_defined_update:								; Call update routine for this sprite.  Ignore if not set
				ld l,( ix + sprite.update_rout.os)
				ld h, ( ix + sprite.update_rout.os + 1)
				ld a,l
				or h
				or a
				jp z,@+next_node
				ld ( @+upd_rout + 1),hl
		@upd_rout: call 0
		
	@next_node:
				call sprite.ll.goto_nextIX
				jp nz,@-update_loop

@end:
				pop iy
				ret

;-------------------------------------------------------
sprite.ageIX:
; Age sprite position
; Move current data into old, 11 bytes from sprite.xL.os into sprite.xL2.os
	@age_sprite:
				ld a,ixl
				ld l,a
				ld a,ixh
				ld h,a
				ld bc,sprite.xL.os
				add hl,bc
				ld e,l
				ld d,h
				ld bc,sprite.frame_data.len
				add hl,bc
				ex de,hl
				for sprite.frame_data.len,ldi
				ret

;-------------------------------------------------------
sprite.set_posA:
; Set position according to code in A
				ld ( ix + sprite.dest.set.os),Off
				cp On
				jp z,@+set_pos
				cp Set_X
				jp z,@+set_x
				cp Set_Y
				jp z,@+set_y
				cp Set_rel
				jp z,@+set_pos_rel
				cp Set_xrel
				jp z,@+set_xrel
				cp Set_yrel
				jp z,@+set_yrel
				ret
	@set_pos:											; Set absolute position
				ld a,( ix + sprite.dest.xL.os)
				ld ( ix + sprite.xL.os),a
				ld ( ix + sprite.dest.xL.os),0
				ld a,( ix + sprite.dest.xH.os)
				ld ( ix + sprite.xH.os),a
				ld a,( ix + sprite.dest.xB.os)
				ld ( ix + sprite.xB.os),a
				ld a,( ix + sprite.dest.yL.os)
				ld ( ix + sprite.yL.os),a
				ld ( ix + sprite.dest.yL.os),0
				ld a,( ix + sprite.dest.yH.os)
				ld ( ix + sprite.yH.os),a
				ld a,( ix + sprite.dest.yB.os)
				ld ( ix + sprite.yB.os),a
				ret
	@set_x:												; Set absolute X position only
				ld a,( ix + sprite.dest.xL.os)
				ld ( ix + sprite.xL.os),a
				ld ( ix + sprite.dest.xL.os),0
				ld a,( ix + sprite.dest.xH.os)
				ld ( ix + sprite.xH.os),a
				ld a,( ix + sprite.dest.xB.os)
				ld ( ix + sprite.xB.os),a
				ret
	@set_y:												; Set absolute Y position only
				ld a,( ix + sprite.dest.yL.os)
				ld ( ix + sprite.yL.os),a
				ld ( ix + sprite.dest.yL.os),0
				ld a,( ix + sprite.dest.yH.os)
				ld ( ix + sprite.yH.os),a
				ld a,( ix + sprite.dest.yB.os)
				ld ( ix + sprite.yB.os),a
				ret
				
	@set_pos_rel:										; Set position relative to current position of sprite IY
		@get_relative_obj:
				ld a,( ix + sprite.rel.obj.os)
				ld iyl,a
				ld a,( ix + sprite.rel.obj.os + 1)
				ld iyh,a
				or a
		@set_pos:
				ld a,( ix + sprite.dest.xL.os)
				adc ( iy + sprite.xL.os)
				ld ( ix + sprite.xL.os),a
				ld a,( ix + sprite.dest.xH.os)
				adc ( iy + sprite.xH.os)
				ld ( ix + sprite.xH.os),a
				ld a,( ix + sprite.dest.xB.os)
				adc ( iy + sprite.xB.os)
				ld ( ix + sprite.xB.os),a

				ld a,( ix + sprite.dest.yL.os)
				adc ( iy + sprite.yL.os)
				ld ( ix + sprite.yL.os),a
				ld a,( ix + sprite.dest.yH.os)
				adc ( iy + sprite.yH.os)
				ld ( ix + sprite.yH.os),a
				ld a,( ix + sprite.dest.yB.os)
				adc ( iy + sprite.yB.os)
				ld ( ix + sprite.yB.os),a
				ret

	@set_xrel:										; Set position relative to current position of sprite IY
		@get_anchor_obj:
				ld a,( ix + sprite.rel.obj.os)
				ld iyl,a
				ld a,( ix + sprite.rel.obj.os + 1)
				ld iyh,a
				or a
		@set_pos:
				ld a,( ix + sprite.dest.xL.os)
				adc ( iy + sprite.xL.os)
				ld ( ix + sprite.xL.os),a
				ld a,( ix + sprite.dest.xH.os)
				adc ( iy + sprite.xH.os)
				ld ( ix + sprite.xH.os),a
				ld a,( ix + sprite.dest.xB.os)
				adc ( iy + sprite.xB.os)
				ld ( ix + sprite.xB.os),a
				ret
				
	@set_yrel:										; Set position relative to current position of sprite IY
		@get_anchor_obj:
				ld a,( ix + sprite.rel.obj.os)
				ld iyl,a
				ld a,( ix + sprite.rel.obj.os + 1)
				ld iyh,a
				or a
		@set_pos:
				ld a,( ix + sprite.dest.yL.os)
				adc ( iy + sprite.yL.os)
				ld ( ix + sprite.yL.os),a
				ld a,( ix + sprite.dest.yH.os)
				adc ( iy + sprite.yH.os)
				ld ( ix + sprite.yH.os),a
				ld a,( ix + sprite.dest.yB.os)
				adc ( iy + sprite.yB.os)
				ld ( ix + sprite.yB.os),a
				ret

;-------------------------------------------------------
sprite.check_dest:
; If destination coords met or overshot then put sprite at destination coords and put speeds to 0.
; Only called from sprite.update_all
@check_arrived:											; Checks based on direction of travel of sprite.
				ld a,( ix + sprite.spd.xH.os)			; If x speed <> 0 then travelling left-right
				or ( ix + sprite.spd.xL.os)
				or a
				jr nz,@left_right

	@up_down:
				ld l,( ix + sprite.dest.yH.os)
				ld h,( ix + sprite.dest.yB.os)
				ld c,( ix + sprite.yH.os)
				ld b,( ix + sprite.yB.os)
				bit 7,( ix + sprite.spd.yH.os)
				jr z,@+down
		@up:											; If dest - current y >= 0 then arrived
				and a
				sbc hl,bc
				jr z,@+stop
				bit 7,h
				jr z,@+stop
				ret
		@down:											; if dest - curr y <=0 then arrived
				and a
				sbc hl,bc
				jr z,@+stop
				bit 7,h
				jr nz,@+stop
				ret

	@left_right:
				ld l,( ix + sprite.dest.xH.os)
				ld h,( ix + sprite.dest.xB.os)
				ld c,( ix + sprite.xH.os)
				ld b,( ix + sprite.xB.os)
				bit 7,( ix + sprite.spd.xH.os)
				jr z,@+right
		@left:
				and a
				sbc hl,bc
				jr z,@+stop
				bit 7,h
				jr z,@+stop
				ret
		@right:
				and a
				sbc hl,bc
				jr z,@+stop
				bit 7,h
				jr nz,@+stop
				ret

	@stop:												; If matched then set destination coord and speed
				ld a,( ix + sprite.dest.xL.os)
				ld ( ix + sprite.xL.os),a
				ld ( ix + sprite.dest.xL.os),0
				ld a,( ix + sprite.dest.xH.os)
				ld ( ix + sprite.xH.os),a
				ld a,( ix + sprite.dest.xB.os)
				ld ( ix + sprite.xB.os),a
				ld a,( ix + sprite.dest.yL.os)
				ld ( ix + sprite.yL.os),a
				ld ( ix + sprite.dest.yL.os),0
				ld a,( ix + sprite.dest.yH.os)
				ld ( ix + sprite.yH.os),a
				ld a,( ix + sprite.dest.yB.os)
				ld ( ix + sprite.yB.os),a

				ld ( ix + sprite.spd.xL.os),0
				ld ( ix + sprite.spd.xH.os),0
				ld ( ix + sprite.spd.yL.os),0
				ld ( ix + sprite.spd.yH.os),0

				ld ( ix + sprite.dest.on.os),No
				ret

;-------------------------------------------------------
sprite.update_frameIX:
; Update animation frame data position
	@update_pos:
				ld l,( ix + sprite.anim.pos.os)
				ld h,( ix + sprite.anim.pos.os + 1)
				for 2,inc hl
	@test_token:										; If next frame is end token, loop from start.anim address
				ld a,(hl)
				cp loop_anim
				jr z,@+loop_anim
				cp eof
				jp z,@+kill_sprite
	@save_pos:											; Preserve new position for animation data
				ld ( ix + sprite.anim.pos.os),l
				ld ( ix + sprite.anim.pos.os + 1),h
				ret

@loop_anim:												; If loop_anim token found, reset position to start of animation
				ld l,( ix + sprite.start.anim.pos.os)
				ld h,( ix + sprite.start.anim.pos.os + 1)
				jp @-save_pos

@kill_sprite:											; If eof token found, this is a one-shot sprite and can be killed
				call sprite.killIX
				ret

;-------------------------------------------------------
sprite.get_frame_dataIXHL:
; Collect new frame from animation data
				ld a,(hl)
				ld ( ix + sprite.frame.os),a
				inc hl
				ld b,(hl)
				ld ( ix + sprite.delay.os),b

	@find_frame_data:									; Get frame data
				ld l,a
				ld h,0
				for 3,add hl,hl
				ld bc,sprite.frames
				add hl,bc
	@get_page:											; Load frame data into sprite slot for easy use
				ld a,(hl)
				ld ( ix + sprite.frame.page.os),a
				inc hl
	@get_src:
				ld a,(hl)
				ld ( ix + sprite.frame.src.os),a
				inc hl
				ld a,(hl)
				ld ( ix + sprite.frame.src.os + 1),a
				inc hl
	@get_width_depth:
				ld a,(hl)
				ld ( ix + sprite.frame.width.os),a
				inc hl
				ld a,(hl)
				ld ( ix + sprite.frame.depth.os),a
				inc hl
	@get_xy_offset:
				ld a,(hl)
				ld ( ix + sprite.x_offset.os),a
				inc hl
				ld a,(hl)
				ld ( ix + sprite.y_offset.os),a
				ret

;-------------------------------------------------------
sprite.print_all:
; Print sprite from data at IX.  Traverse through all sprites in linked list backwards, so first sprites appear on top

@check_active:
				ld a,(int.sprites.on)
				cp Off
				ret z

@check_sprite_list:
				ld a,(sprite.ll.count)
				or a
				ret z

				ld ix,(sprite.ll.final)
@print_loop:
	@test_new:
				ld a,( ix + sprite.birth.os)
				cp 2
				jp nc,@+next_node
	@test_anim:											; If no animation assigned, don't print sprite
				xor a
				cp ( ix + sprite.anim.os)
				jr z,@+next_node
	@test_dying:										; If being destroyed, don't reprint, unless die_visible is on
				cp ( ix + sprite.death.os)
				jr z,@+test_visible
				cp ( ix + sprite.die_visible.os)
				jr nz,@+next_node
				ld a,( ix + sprite.death.os)
				cp 2
				jp nz,@+next_node
	@test_visible:										; If invisible, don't reprint
				ld a,On
				cp ( ix + sprite.invisible.os)
				jr z,@+next_node

	@get_print_rout:
				ld l,( ix + sprite.print_rout.os)
				ld h,( ix + sprite.print_rout.os + 1)
				ld ( @+print_rout + 1),hl

	@print_rout: call 0

	@next_node:
				call sprite.ll.goto_previousIX
				jr nz,@-print_loop
				ret

;-------------------------------------------------------
sprite.replace_bgd_all:
; Reprint background over old sprite data
@check_active:
				ld a,(int.sprites.on)
				cp Off
				ret z

@check_sprite_list:
				ld a,(sprite.ll.count)
				or a
				ret z

				ld ix,(sprite.ll.first)
@replace_loop:
	@test_anim:
				xor a
				cp ( ix + sprite.anim.os)
				jr z,@+next_node
				cp ( ix + sprite.invisible.os)
				jr z,@+next_node
	@test_birthing:										; If being created, don't replace old frames yet
				cp ( ix + sprite.birth.os)
				jr nz,@+next_node
	@test_dying_visible:								; If dying visibly, don't replace background
				cp ( ix + sprite.death.os)
				jr z,@+get_clear_rout					; if death count = 0 then sprite not dying, skip other check
				; ld a,On
				cp ( ix + sprite.die_visible.os)
				jr z,@+next_node						; If die_visible is On then skip clearing

	@get_clear_rout:
				ld l,( ix + sprite.clear_rout.os)
				ld h,( ix + sprite.clear_rout.os + 1)
				ld ( @+clear_rout + 1),hl

	@clear_rout: call 0									; Call allocated replace background routine

	@next_node:
				call sprite.ll.goto_nextIX
				jr nz,@-replace_loop
				ret

;-------------------------------------------------------

;=======================================================

