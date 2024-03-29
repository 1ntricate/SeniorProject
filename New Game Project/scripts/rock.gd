extends CharacterBody2D

var player = null
var health = 100
var dmg_taken_cooldown = true
var player_inrange = false
var rock_from_rock = 100
var rock_harvest = 0

func _ready():
	$AnimatedSprite2D.play("100")

func _physics_process(delta):
	deal_dmg()
	update_rock_hp()
	
func _on_area_2d_body_entered(body):
	if body.has_method("player"):
		player_inrange = true

func _on_area_2d_body_exited(body):
	if body.has_method("player"):
		player_inrange = false

func tree():
	pass

func deal_dmg():
	if player_inrange and Global.player_current_atk == true:
		if dmg_taken_cooldown == true:
			health -= 20
			rock_from_rock -= 20
			rock_harvest = 100 - rock_from_rock
			$take_dmg_cooldown.start()
			dmg_taken_cooldown = false
			if health < 60 and health > 30:
				$AnimatedSprite2D.play("50")
			elif health < 30:
				$AnimatedSprite2D.play("0")
			print("rock health: ", health)
			print("+", rock_harvest, " rock")
			if health <= 0:
				self.queue_free()

func _on_take_dmg_cooldown_timeout():
	dmg_taken_cooldown = true

func update_rock_hp():
	var rockbar = $RockHp
	rockbar.value = health
	if health > 100:
		rockbar.visible = false
	else:
		rockbar.visible = true




