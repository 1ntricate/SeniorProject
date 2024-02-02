extends Node

var drink = 0
var player_current_atk = false
var selected_image_path = ""
var auto_movement_enabled = true

func _process(delta):
	pass

func _on_button_pressed():
	pass
	
func setAutoMovementEnabled(enabled):
	auto_movement_enabled = enabled
	
func isAutoMovementEnabled():
	return auto_movement_enabled
