extends "res://scripts/base_enemy_class.gd"

func _ready():
	speed = 30
	health = 400
	enemybar = $Skeleton_Hp

func update_enemy_hp():
	enemybar.value = health
	
func _physics_process(delta):
	var separation_force = Vector2.ZERO
	deal_dmg()
	update_enemy_hp()
	if auto_movement_enabled:
		# Move automatically left or right
		position += movement_direction * speed * delta 
		
		# Check if the enemy has reached the right edge of the map
		if position.x > get_viewport_rect().size.x:
			movement_direction = Vector2.LEFT

		# Check if the enemy has reached the left edge of the map
		elif position.x < 0:
			movement_direction = Vector2.RIGHT
		#emit_signal("position_changed", global_transform.origin,"skeleton")		
	if player_chase:
		# can be adjusted so enemies run away from player instead of chasing
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("move")

		# player on the left side of the enemy -> flip
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
			movement_direction = Vector2.LEFT
		else:
			$AnimatedSprite2D.flip_h = false
			movement_direction = Vector2.RIGHT
		#emit_signal("position_changed", global_transform.origin,"skeleton")	
	else:
		$AnimatedSprite2D.play("idle")
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy != self and position.distance_to(enemy.position) < 100: 
			separation_force += position.direction_to(enemy.position).normalized()
	
	if separation_force.length() > 0:
		position -= separation_force.normalized() * speed * delta  * 2

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	auto_movement_enabled = false  # Stop automatic movement when player is in range

func skeleton():
	pass

func _on_dead_timer_timeout():
	queue_free()

func _on_hitbox_area_area_entered(area):
	if area.is_in_group("projectile"):
		health -= 100
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.modulate = Color.WHITE
		if health <= 0:
			$AnimatedSprite2D.play("dead")
			$dead_timer.start()
			dmg_taken_cooldown = false
			$take_dmg_cooldown.stop()
			Global.skeleton_count-= 1	
	