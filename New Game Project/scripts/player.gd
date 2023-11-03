extends KinematicBody2D

var velocity: Vector2 = Vector2()
var direction: Vector2 = Vector2()
var click_position: Vector2 = Vector2()
var cur_dir = "none"
var is_attacking = false
onready var animation = $AnimatedSprite
var speed = 100

func _ready():
	animation.play("front_idle")

func read_input():
	velocity = Vector2()
	var new_direction = "none"
	var movement = 0

#	move character by mouse:
#	var target_position = (click_position - position).normalized()
#
#	if Input.is_action_just_pressed("left_mouse"):
#		click_position = get_global_mouse_position()
#	if position.distance_to(click_position) > 3:
#		move_and_slide(target_position * speed)
#		look_at(click_position)
	
#	press 'k' to attack	
	if Input.is_action_pressed("attack"):
		is_attacking = true
		play_attack_animation()
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
	velocity = move_and_slide(velocity * 200)

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
	match cur_dir:
		"right":
			animation.set_flip_h(false)
			animation.play("attack_side")
		"left":
			animation.set_flip_h(true)
			animation.play("attack_side")
		"down":
			animation.set_flip_h(true)
			animation.play("attack_down")
		"up":
			animation.set_flip_h(true)
			animation.play("attack_up")

func _physics_process(delta):
	read_input()
