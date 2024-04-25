extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_new_map_button_pressed():
	Global.mobile_joined = false
	get_tree().change_scene_to_file("res://scenes/select_img_to_process.tscn")

func _on_browse_maps_button_pressed():
	Global.mobile_joined = false
	get_tree().change_scene_to_file("res://scenes/map_list.tscn")
	
	pass # Replace with function body.


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MapMenu.tscn")

func _on_rand_map_pressed():
	Global.mobile_joined = false
	get_tree().change_scene_to_file("res://scenes/randomized_game_map.tscn")


func _on_public_pressed():
	get_tree().change_scene_to_file("res://scenes/public_maps.tscn")

