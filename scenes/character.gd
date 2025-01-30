extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800



func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			pass
		else:			 
			$runColl.disabled = false
			if Input.is_action_pressed('ui_left'):
				velocity.y = -1400
				$AnimatedSprite2D.play("jump")
				$AudioStreamPlayer.play()
			if Input.is_action_pressed('ui_right'):
				velocity.y = JUMP_SPEED
				$AnimatedSprite2D.play("jump")
				$AudioStreamPlayer.play()
			elif Input.is_action_pressed('ui_down'):
				$AnimatedSprite2D.play('slide')
				$runColl.disabled = true
			else:
				$AnimatedSprite2D.play('run')
	move_and_slide()
