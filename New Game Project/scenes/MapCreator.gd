extends Control

@onready var map_name = get_node("%MapName")
@onready var map_dsc = get_node("%MapDescription")


# Called when the node enters the scene tree for the first time.
func _ready():
	var text_box = $TextEdit
	text_box.text = "Elements Identified"
	var elements = Global.elements_identfied
	text_box.text = elements
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_save_button_pressed():
	Global.map_name = map_name.get_text()
	var dsc = map_dsc.get_text()
	get_tree().change_scene_to_file("res://scenes/processed_game_map.tscn")



func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MapMenu.tscn")
	
