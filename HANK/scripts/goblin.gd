extends "res://scripts/base_enemy_class.gd"

func _ready():
	health = 200
	enemybar = $Goblin_Hp
	
func update_enemy_hp():
	enemybar.value = health
	
func _physics_process(delta):
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
		emit_signal("position_changed", global_transform.origin,"goblin")	
				
	if player_chase:
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("move")

		# player on the left side of the enemy -> flip
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
			movement_direction = Vector2.LEFT
		else:
			$AnimatedSprite2D.flip_h = false
			movement_direction = Vector2.RIGHT
		emit_signal("position_changed", global_transform.origin,"goblin")	
	else:
		$AnimatedSprite2D.play("idle")
	if health <= 0:
		self.queue_free()
		Global.goblin_count -= 1
	var separation_force = Vector2.ZERO
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy != self and position.distance_to(enemy.position) < 60: 
			separation_force += position.direction_to(enemy.position).normalized()
	
	if separation_force.length() > 0:
		position -= separation_force.normalized() * speed * delta  * 0.8

func goblin():
	pass

func _on_hitbox_area_area_entered(area):
	if area.is_in_group("projectile"):
		health -= 50
		$take_dmg_cooldown.start()
		dmg_taken_cooldown = false
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.modulate = Color.WHITE
		print("goblin health: ", health)
		if health <= 0:
			$AnimatedSprite2D.play("dead")
			self.queue_free()
			Global.goblin_count -= 1
	
