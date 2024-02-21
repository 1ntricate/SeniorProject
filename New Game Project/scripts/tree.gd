extends CharacterBody2D

var player = null
var health = 100
var dmg_taken_cooldown = true
var player_inrange = false
var wood_from_tree = 100
var wood_harvest = 0

func _ready():
	$AnimatedSprite2D.play("tree")

func _physics_process(delta):
	deal_dmg()
	update_tree_hp()
	
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
			wood_from_tree -= 20
			wood_harvest = 100 - wood_from_tree
			if health <= 40:
				$AnimatedSprite2D.play("wood")
			$take_dmg_cooldown.start()
			dmg_taken_cooldown = false
			print("tree health: ", health)
			print("+", wood_harvest, " wood")
			if health <= 0:
				Global.instance.tree_fallen = true
				self.queue_free()

func _on_take_dmg_cooldown_timeout():
	dmg_taken_cooldown = true

func update_tree_hp():
	var treebar = $Tree_Hp
	treebar.value = health
	if health > 100:
		treebar.visible = false
	else:
		treebar.visible = true

