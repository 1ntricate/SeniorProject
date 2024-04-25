extends CharacterBody2D

var enemybar = ""
var speed = 45
var player_chase = false
var player = null
var bullet = null
var health = ""
var player_inrange = false
var bullet_inrange = false
var dmg_taken_cooldown = true
var random = randi() % 2
var auto_movement_enabled = true
var movement_direction = Vector2.LEFT  # Initial direction
@onready var animation = $AnimatedSprite2D

func _ready():
	Engine.time_scale = 1
	animation.play("idle")
	
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
		emit_signal("position_changed", global_transform.origin, "slime")	
				
	if player_chase:
		position += (player.position - position) / speed
#		$AnimatedSprite2D.play("move")

		# player on the left side of the enemy -> flip
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = false
			movement_direction = Vector2.LEFT
		else:
			$AnimatedSprite2D.flip_h = true
			movement_direction = Vector2.RIGHT
		emit_signal("position_changed", global_transform.origin,"slime")	
	else:
		$AnimatedSprite2D.play("idle")

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_chase = true
		auto_movement_enabled = false
	  # Stop automatic movement when player is in range

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	auto_movement_enabled = true  # Resume automatic movement when player is out of range

func enemy():
	pass

func _on_enemyhitbox_body_entered(body):
	if body.has_method("player"):
		player_inrange = true

func _on_enemyhitbox_body_exited(body):
	if body.has_method("player") or body.is_in_group("player"):
		player_inrange = false

func deal_dmg():
	if player_inrange and Global.player_current_atk == true:
		if dmg_taken_cooldown == true:
			if Global.player_axe_atk:
				if Global.melee_equipped != null:
					health -= Global.player_base_dmg * Global.weapon_dmg
					$AnimatedSprite2D.modulate = Color.RED
			else: 
				health -= 25
			$take_dmg_cooldown.start()
			dmg_taken_cooldown = false
			print("slime health: ", health)
			if health <= 40 and health > 0:
				$AnimatedSprite2D.play("dead")
			elif health <= 0:
				self.queue_free()
				Global.slime_count -= 1

func _on_take_dmg_cooldown_timeout():
	$AnimatedSprite2D.modulate = Color.WHITE
	dmg_taken_cooldown = true

func _on_enemyhitbox_area_entered(area):
	if area.is_in_group("projectile"):
		health -=25
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.modulate = Color.WHITE
		if health <= 40 and health > 0:
			$AnimatedSprite2D.play("dead")
		elif health <= 0:
			self.queue_free()
			Global.slime_count -= 1
	
func update_enemy_hp():
	enemybar.value = health
