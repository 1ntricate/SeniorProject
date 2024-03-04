extends CharacterBody2D

var speed = 25
var player_chase = false
var player = null
var health = 150
var player_inrange = false
var dmg_taken_cooldown = true
var random = randi() % 2
var auto_movement_enabled = true
var movement_direction = Vector2.UP  # Initial direction
@onready var animation = $AnimatedSprite2D

func _ready():
	Engine.time_scale = 1
	animation.play("idle")
	
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
	if auto_movement_enabled:
		# Move automatically left or right
		position += movement_direction * speed * delta

		if position.y > get_viewport_rect().size.y:
			movement_direction = Vector2.DOWN
		else:
			movement_direction = Vector2.UP
				
	if player_chase:
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("move_right")
		check_direction()
	else:
		$AnimatedSprite2D.play("idle")

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	auto_movement_enabled = false  # Stop automatic movement when player is in range

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	auto_movement_enabled = true  # Resume automatic movement when player is out of range

func spider():
	pass

func _on_hitbox_area_body_entered(body):
	if body.has_method("player"):
		player_inrange = true

func _on_hitbox_area_body_exited(body):
	if body.has_method("player"):
		player_inrange = false

func deal_dmg():
	if player_inrange and Global.player_current_atk == true:
		if dmg_taken_cooldown == true:
			if Global.player_axe_atk:
				health -=70
			else: 
				health -= 35
			$take_dmg_cooldown.start()
			dmg_taken_cooldown = false
			print("spider health: ", health)
			if health <= 0:
#				$AnimatedSprite2D.play("dead")
				self.queue_free()
				Global.spider_count -= 1

func _on_take_dmg_cooldown_timeout():
	dmg_taken_cooldown = true

func update_enemy_hp():
	var enemybar = $Spider_Hp
	enemybar.value = health
	if health > 150:
		enemybar.visible = false
	else:
		enemybar.visible = true



func _on_hitbox_area_area_entered(area):
	if area.is_in_group("projectile"):
		health -= 35
		if health <= 0:
			$AnimatedSprite2D.play("dead")
			self.queue_free()
			Global.spider_count -= 1
