extends "res://scripts/base_enemy_class.gd"

signal position_changed(new_position)
func _ready():
	speed = 25
	health = 150
	enemybar = $Spider_Hp
	
func check_direction():
	var player_pos = player.position
	var enemy_pos = position
	var angle_to_player = (player_pos - enemy_pos).angle()

	if abs(angle_to_player) < 45 or abs(angle_to_player) > 315:
		# Player is to the right
		$AnimatedSprite2D.play("move_right")
		movement_direction = Vector2.RIGHT
	elif abs(angle_to_player) > 135 and abs(angle_to_player) < 225:
		# Player is to the left
		$AnimatedSprite2D.flip_h = true
		movement_direction = Vector2.LEFT
	elif angle_to_player < 135 and angle_to_player > 45:
		# Player is above
		$AnimatedSprite2D.play("move_up")
		movement_direction = Vector2.UP
	else:
		# Player is below
		$AnimatedSprite2D.flip_h = true
		movement_direction = Vector2.DOWN
	
func _physics_process(delta):
	deal_dmg()
	update_enemy_hp()
	if Global.spider_on_sand:
		print("Spider on Sand")
	if auto_movement_enabled:
		# Move automatically left or right
		position += movement_direction * speed * delta
		if position.y > get_viewport_rect().size.y:
			movement_direction = Vector2.DOWN
		else:
			movement_direction = Vector2.UP
		emit_signal("position_changed", global_transform.origin,"spider")		
	if player_chase:
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("move_right")
		check_direction()
		emit_signal("position_changed", global_transform.origin,"spider")		
	else:
		$AnimatedSprite2D.play("idle")
	if health <= 0:
		self.queue_free()
		Global.spider_count -= 1
	
func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	auto_movement_enabled = false  # Stop automatic movement when player is in range

func spider():
	pass
	
func _on_hitbox_area_area_entered(area):
	if area.is_in_group("projectile"):
		health -= 35
		if health <= 0:
			$AnimatedSprite2D.play("dead")
			self.queue_free()
			Global.spider_count -= 1

