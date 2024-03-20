extends CharacterBody2D

@onready var timer_label = $countdown
@onready var countdown = $survival_timer

var enemy_in_range = false
var goblin_in_range = false
var skeleton_in_range = false
var spider_in_range = false
var enemy_atk_cooldown = true
var goblin_atk_cooldown = true
var skeleton_atk_cooldown = true
var spider_atk_cooldown = true
var is_attacking = false
var alive = true
var inventory_on = false
var key_input = false

var health = 100
var hunger = 100
var thirsty = 100
var movement = 0
var b
var direction: Vector2 = Vector2()
var click_position: Vector2 = Vector2()
var cur_dir = "none"
var new_direction = "none"
var slow_attack = false
var drown = true

@onready var mobile_button	  = $onscreen_button
@onready var button 		  = $InputKey
@onready var animation 		  = $AnimatedSprite2D
@onready var weapon_animation = $AnimationPlayer
@onready var inventory 		  = $Inventory
@onready var weapon 		  = $weapon
@onready var axe    		  = $weapon/axe
@onready var sword  		  = $weapon/sword

@onready var bullet = preload("res://scenes/bullet.tscn")

var gravity := 50
#@onready var pause_menu = $PauseMenu
var isPaused = false
var speed = 100
var player_immunity = true
var last_dir: String = "Down"

func _ready():
	Engine.time_scale = 1
	#countdown.wait_time = 1.0
	countdown.start()
	animation.play("m_walk_down")
	animation.set_flip_h(false)
	$hunger_timer.start()
	$thirsty_timer.start()
	if Global.mobile_joined:
		mobile_button.visible = true
	else:
		mobile_button.visible = false
	
func _physics_process(delta):
	timer_label.text = "%02d:%02d" % survival_timer()
	healing()
	read_input()
	enemy_atk()
	goblin_atk()
	skeleton_atk()
	spider_atk()
	update_hp()
	update_hunger_bar()
	update_thirsty_bar()
	attack_slowdown()
	if drown:
		drown_player()
	#shoot()

	if health <= 0:
		alive = false 
		health = 0
		print("You are dead")
		get_tree().change_scene_to_file("res://scenes/Gameover.tscn")
	if Input.is_action_just_pressed("escape"):
		pauseMenu()
		
func shoot():
	if Input.is_action_just_pressed("shoot") and $shoot_timer.is_stopped():
		var b = bullet.instantiate()
		get_parent().add_child(b)
		# bullet spawn pos
		b.global_position = $Marker2D.global_position
		# firing direction
		var mouse_position = get_global_mouse_position()
		var direction = (mouse_position - b.global_position).normalized()
		b.direction = direction
		b.speed = 700
		# rotate bullet to firing direction
		b.rotation = atan2(direction.y,direction.x)
		# Start the timer after shooting
		$shoot_timer.start()

func survival_timer():
	var time_left = countdown.time_left
	var min = floor(time_left/60)
	var sec = int(time_left) % 60
	return [min,sec]
	
func read_input():
	velocity = Vector2()
	# press j for key
	if  Input.is_action_just_pressed("key_input") and key_input == false:
		button.visible = true
		key_input = true
		Global.is_changing_key_input = true
	elif Input.is_action_just_pressed("key_input") and key_input == true:
		button.visible = false
		key_input = false
		#Global.is_changing_key_input = false
		
	# press I for inventory
	if  (Input.is_action_just_pressed("inventory") or Global.player_on_screen_button_right == "inven") and inventory_on == false:
		inventory.visible = true
		inventory_on = true
	elif(Input.is_action_just_pressed("inventory") or Global.player_on_screen_button_right == "inven") and inventory_on == true:
		inventory.visible = false
		inventory_on = false
	
		
	# check what weapons are equipped	
		 # equipped on slot 1 
	if Global.melee_equipped == "axe":
		if (Input.is_action_pressed("axe_attack") or Global.player_on_screen_button_right == "atk") and $axe_timer.is_stopped():
			Global.player_axe_atk = true
			Global.player_current_atk = true
			#Global.player_atk = true
			is_attacking = true
			axe.visible = true
			weapon_animation.play("axe" +last_dir)
			$axe_timer.start()	
		elif Input.is_action_just_released("axe_attack") or Global.player_on_screen_button_right == "":
			is_attacking = false
			Global.player_axe_atk = false
			Global.player_current_atk = false
			#Global.player_atk = false
			is_attacking = false
			axe.visible = false
			
	elif Global.melee_equipped == "sword":
		if (Input.is_action_pressed("axe_attack") or Global.player_on_screen_button_right == "atk") and $axe_timer.is_stopped():
			Global.player_axe_atk = true
			Global.player_current_atk = true
			#Global.player_atk = true
			is_attacking = true
			sword.visible = true
			weapon_animation.play("axe" +last_dir)
			$axe_timer.start()	
		elif Input.is_action_just_released("axe_attack") or Global.player_on_screen_button_right == "":
			is_attacking = false
			Global.player_axe_atk = false
			Global.player_current_atk = false
			#Global.player_atk = false
			is_attacking = false
			sword.visible = false
		 
		#equipped on slot 2	
	if Global.ranged_equipped == "gun":	
		if Input.is_action_pressed("shoot"):
			is_attacking = true
			shoot()
		else:
		#press 'k' to attack	
			if Input.is_action_pressed("attack"):
				is_attacking = true
				play_attack_animation()
			
	check_moving_input() #check WASD for movement
			
			
	# update direction
	if new_direction != cur_dir:
		cur_dir = new_direction
		play_animation(movement)
	else:
		play_animation(0)

	velocity = velocity.normalized()
	
	
	# update speed based on environment
	if Global.player_on_water:
		if $drown_timer.is_stopped():
			$drown_timer.start()
			print("drown timer started")
		if !slow_attack:
			slow_attack = true
			print("slow attack")
		set_velocity(velocity * 100)
		thirsty += .10
		velocity = velocity
	elif Global.player_on_sand:
		$drown_timer.stop()
		drown = false
		slow_attack = false
		thirsty -= .005
		set_velocity(velocity * 150)
		velocity = velocity
	else:
		drown = false
		$drown_timer.stop()
		$AnimatedSprite2D.modulate = Color.WHITE
		slow_attack = false
		set_velocity(velocity * 200)
		velocity = velocity
	move_and_slide()

func attack_slowdown():
	if slow_attack:
		#print("Attacks slowed")
		$atk_cooldown.wait_time = 2.5
		$shoot_timer.wait_time = 1.0
		$axe_timer.wait_time = 2.0
	else:
		$atk_cooldown.wait_time = 1.5
		$shoot_timer.wait_time = 0.5
		$axe_timer.wait_time = 1
		
# WASD movements 	
func check_moving_input():
	if Input.is_action_pressed("up") or Global.player_on_screen_button_left == "w":
		last_dir = "up"
		new_direction = "up"
		velocity.y -= 1
		direction = Vector2(0, -1)
		movement = 1
	elif Input.is_action_pressed("down") or Global.player_on_screen_button_left == "s":
		new_direction = "down"
		last_dir = new_direction
		velocity.y += 1
		direction = Vector2(0, 1)
		movement = 1

	if Input.is_action_pressed("left") or Global.player_on_screen_button_left == "a":
		new_direction = "left"
		last_dir = new_direction
		velocity.x -= 1
		direction = Vector2(-1, 0)
		movement = 1
	elif Input.is_action_pressed("right") or Global.player_on_screen_button_left == "d":
		new_direction = "right"
		last_dir = new_direction
		velocity.x += 1
		direction = Vector2(1, 0)
		movement = 1
	
func play_animation(movement):
	#print("Direction: ", cur_dir, ", Flipped: ", animation.is_flipped_h())
	match cur_dir:
		"right":
			animation.set_flip_h(false)
			if movement == 1:
				animation.play("m_walk_side")
			#else:
			#	animation.play("side_idle")
		"left":
			animation.set_flip_h(true)
			if movement == 1:
				animation.play("m_walk_side")
			#else:
			#	animation.play("side_idle")
		"down":
			#animation.set_flip_h(true)
			if movement == 1:
				animation.play("m_walk_down")
			#else:
			#	animation.play("front_idle")
		"up":
			#animation.set_flip_h(true)
			if movement == 1:
				animation.play("m_walk_up")
			#else:
			#	animation.play("back_idle")

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
		

func player():
	pass

func healing():
	if Global.current_tree_hp_0 == true:
		health += 10
		hunger += 10
		Global.current_tree_hp_0 = false
		
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
	if enemy_in_range and enemy_atk_cooldown == true and player_immunity == false:
		health -= 3
		enemy_atk_cooldown = false
		$atk_cooldown.start()
		#print(health)

func goblin_atk():	
	#goblin attack dmg
	if goblin_in_range and goblin_atk_cooldown == true and player_immunity == false:
		health -= 8
		goblin_atk_cooldown = false
		$goblin_atk_cooldown.start()
		#print(health)		
		
func skeleton_atk():	
	#goblin attack dmg
	if skeleton_in_range and skeleton_atk_cooldown == true and player_immunity == false:
		health -= 10
		skeleton_atk_cooldown = false
		$skeleton_atk_cooldown.start()
		#print(health)	

func spider_atk():	
	if spider_in_range and spider_atk_cooldown == true and player_immunity == false:
		health -= 5
		spider_atk_cooldown = false
		$spider_atk_cooldown.start()
		#print(health)		

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
		#print("Hunger:", hunger)

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
		#print("Thirsty:", thirsty)

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

func _on_spawn_immunity_timeout():
	player_immunity = false

func _on_survival_timer_timeout():
	Global.spawn_enemies = true
	pass # Replace with function body.

func drown_player():
	print("drowning!")
	health -= 0.5

func _on_drown_timer_timeout():
	print("drown timer ended")
	drown = true
	$AnimatedSprite2D.modulate = Color.AQUA
			
