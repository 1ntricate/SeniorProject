extends CharacterBody2D

var speed = 30
var player_chase = false
var player = null
var health = 400
var player_inrange = false
var dmg_taken_cooldown = true
var random = randi() % 2
var auto_movement_enabled = true
var movement_direction = Vector2.RIGHT  # Initial direction
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
		emit_signal("position_changed", global_transform.origin,"skeleton")		
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
		emit_signal("position_changed", global_transform.origin,"skeleton")	
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

func skeleton():
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
				health -=200
			else: 
				health -= 100
			$take_dmg_cooldown.start()
			dmg_taken_cooldown = false
			print("skeleton health: ", health)
			if health <= 0:
				$AnimatedSprite2D.play("dead")
				$dead_timer.start()
				dmg_taken_cooldown = false
				$take_dmg_cooldown.stop()
				Global.skeleton_count-= 1

func _on_take_dmg_cooldown_timeout():
	dmg_taken_cooldown = true

func update_enemy_hp():
	var enemybar = $Skeleton_Hp
	enemybar.value = health
	if health > 400:
		enemybar.visible = false
	else:
		enemybar.visible = true

func _on_dead_timer_timeout():
	queue_free()


func _on_hitbox_area_area_entered(area):
	if area.is_in_group("projectile"):
		health -= 100
		if health <= 0:
			$AnimatedSprite2D.play("dead")
			$dead_timer.start()
			dmg_taken_cooldown = false
			$take_dmg_cooldown.stop()
			Global.skeleton_count-= 1	
	
