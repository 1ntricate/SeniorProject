extends CharacterBody2D

var player = null
var player_inrange = false


func _physics_process(delta):
	pass
	
func _on_area_2d_body_entered(body):
	if body.has_method("player"):
		player_inrange = true

func _on_area_2d_body_exited(body):
	if body.has_method("player"):
		player_inrange = false

func water():
	pass






