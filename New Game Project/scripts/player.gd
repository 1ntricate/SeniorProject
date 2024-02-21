extends CharacterBody2D

var enemy_in_range = false
var goblin_in_range = false
var skeleton_in_range = false
var spider_in_range = false
var enemy_atk_cooldown = true
var goblin_atk_cooldown = true
var skeleton_atk_cooldown = true
var spider_atk_cooldown = true
var health = 100
var hunger = 100
var thirsty = 100
var alive = true

var direction: Vector2 = Vector2()
var click_position: Vector2 = Vector2()
var cur_dir = "none"
var is_attacking = false

@onready var animation = $AnimatedSprite2D
#@onready var pause_menu = $PauseMenu
var isPaused = false
var speed = 100

func _ready():
	Engine.time_scale = 1
	animation.play("front_idle")
	$hunger_timer.start()
	$thirsty_timer.start()
	#%PauseContainer.visible = false

func read_input():
	velocity = Vector2()
	var new_direction = "none"
	var movement = 0
	
	# press 'spacebar' to shoot laser
#	if Input.is_action_just_pressed("laser"):
#		Global.is_laser = true
#		Global.shoot_laser = true
#		Global.player_cur_dir = cur_dir
#		Global.player_current_atk = true
#	elif Input.is_action_just_released("laser"):
#		Global.is_laser = false
#		Global.shoot_laser = false

#	press 'k' to attack	
	if Input.is_action_pressed("attack"):
		is_attacking = true
		play_attack_animation()
	elif Input.is_action_just_released("attack"):
		is_attacking = false
#	moving with 'WASD'
	else:
		if Input.is_action_pressed("up"):
			new_direction = "up"
			velocity.y -= 1
			direction = Vector2(0, -1)
			movement = 1
		elif Input.is_action_pressed("down"):
			new_direction = "down"
			velocity.y += 1
			direction = Vector2(0, 1)
			movement = 1

		if Input.is_action_pressed("left"):
			new_direction = "left"
			velocity.x -= 1
			direction = Vector2(-1, 0)
			movement = 1
		elif Input.is_action_pressed("right"):
			new_direction = "right"
			velocity.x += 1
			direction = Vector2(1, 0)
			movement = 1
		
	if new_direction != cur_dir:
		cur_dir = new_direction
		play_animation(movement)
	else:
		play_animation(0)

	velocity = velocity.normalized()
	set_velocity(velocity * 200)
	move_and_slide()
	velocity = velocity
	
func play_animation(movement):
	match cur_dir:
		"right":
			animation.set_flip_h(false)
			if movement == 1:
				animation.play("walk_side")
			else:
				animation.play("side_idle")
		"left":
			animation.set_flip_h(true)
			if movement == 1:
				animation.play("walk_side")
			else:
				animation.play("side_idle")
		"down":
			animation.set_flip_h(true)
			if movement == 1:
				animation.play("walk_down")
			else:
				animation.play("front_idle")
		"up":
			animation.set_flip_h(true)
			if movement == 1:
				animation.play("walk_up")
			else:
				animation.play("back_idle")

func play_attack_animation():
	Global.player_current_atk = true
	match cur_dir:
		"right":
			animation.set_flip_h(false)
			animation.play("attack_side")
			$deal_dmg_cooldown.start()
		"left":
			animation.set_flip_h(true)
			animation.play("attack_side")
			$deal_dmg_cooldown.start()
		"down":
			animation.set_flip_h(true)
			animation.play("attack_down")
			$deal_dmg_cooldown.start()
		"up":
			animation.set_flip_h(true)
			animation.play("attack_up")
			$deal_dmg_cooldown.start()

func health_condition():	
	if health <= 0:
		health = 0
	if health > 100:
		health = 100
		
func _physics_process(delta):
	read_input()
	enemy_atk()
	goblin_atk()
	skeleton_atk()
	spider_atk()
	update_hp()
	update_hunger_bar()
	update_thirsty_bar()
	if Global.shoot_laser == true:
#		Global.player_current_atk = true
		print("shoottt")
	if health <= 0:
		alive = false 
		health = 0
		print("You are dead")
		get_tree().change_scene_to_file("res://scenes/Gameover.tscn")
	if Input.is_action_just_pressed("escape"):
		pauseMenu()
		
func player():
	pass

func pauseMenu():
	if isPaused:
		%PauseMenu.hide()
		Engine.time_scale = 1
	else:
		%PauseMenu.show()
		Engine.time_scale = 0
		
	isPaused = !isPaused
	
func _on_playerhitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_in_range = true
	if body.has_method("goblin"):
		goblin_in_range = true
	if body.has_method("skeleton"):
		skeleton_in_range = true
	if body.has_method("spider"):
		spider_in_range = true
	if body.has_method("water"):
		if is_attacking == true:
			thirsty += 5
	if body.has_method("gem"):
		health += 10

func _on_playerhitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_in_range = false
	if body.has_method("goblin"):
		goblin_in_range = false
	if body.has_method("skeleton"):
		skeleton_in_range = false
	if body.has_method("spider"):
		spider_in_range = false

func enemy_atk():
	#slime attack dmg
	if enemy_in_range and enemy_atk_cooldown == true:
		health -= 20
		enemy_atk_cooldown = false
		$atk_cooldown.start()
		print(health)

func goblin_atk():	
	#goblin attack dmg
	if goblin_in_range and goblin_atk_cooldown == true:
		health -= 15
		goblin_atk_cooldown = false
		$goblin_atk_cooldown.start()
		print(health)		
		
func skeleton_atk():	
	#goblin attack dmg
	if skeleton_in_range and skeleton_atk_cooldown == true:
		health -= 25
		skeleton_atk_cooldown = false
		$skeleton_atk_cooldown.start()
		print(health)	

func spider_atk():	
	if spider_in_range and spider_atk_cooldown == true:
		health -= 25
		spider_atk_cooldown = false
		$spider_atk_cooldown.start()
		print(health)		

func _on_skelton_atk_cooldown_timeout():
	skeleton_atk_cooldown = true
	health_condition()

func _on_spider_atk_cooldown_timeout():
	spider_atk_cooldown = true
	health_condition()
		
func _on_atk_cooldown_timeout():
	enemy_atk_cooldown = true
	health_condition()
		
func _on_goblin_atk_cooldown_timeout():
	goblin_atk_cooldown = true
	health_condition()
		
func _on_deal_dmg_cooldown_timeout():
	$deal_dmg_cooldown.stop()
	Global.player_current_atk = false
	is_attacking = false

func update_hp():
	var hpbar = $Player_HP
	hpbar.value = health
	if health > 100:
		health = 100
	else:
		hpbar.visible = true
		
func _on_hunger_timer_timeout():
	# Decrease hunger by 1 every second
	if hunger > 0:
		hunger -= 1
		print("Hunger:", hunger)

	# Check if the player is starving
	if hunger == 0:
		health -= 1
		hunger = 0
		print("You are starving!")
		
func update_hunger_bar():
	var hungerbar = $HungerBar
	hungerbar.value = hunger
	if hunger > 100:
		hunger = 100

func _on_thirsty_timer_timeout():
	# Decrease thirsty by 1 every second
	if thirsty > 0:
		thirsty -= 1
		print("Thirsty:", thirsty)

	# Check if the player is starving
	if thirsty == 0:
		health -= 1
		thirsty = 0
		print("You need water!")
	
func update_thirsty_bar():
	var thirstybar = $ThirstyBar
	thirstybar.value = thirsty
	if thirsty > 100:
		thirsty = 100

func _on_replay_pressed():
	get_tree().paused = false

