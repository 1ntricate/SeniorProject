extends Control

@onready var MainMapContainer = get_node("%MainMapContainer")
# Called when the node enters the scene tree for the first time.

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mobile_button_pressed():
	Global.mobile_joined = true
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	pass # Replace with function body.


func _on_back_button_pressed():
	Global.mobile_joined = false
	MainMapContainer.visible = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	
func _on_browse_maps_button_pressed():
	Global.mobile_joined = false
	get_tree().change_scene_to_file("res://scenes/map_selector.tscn")



func _on_images_pressed():
	get_tree().change_scene_to_file("res://scenes/image_list.tscn")
