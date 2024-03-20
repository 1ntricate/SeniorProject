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
	print("map_name in map creator is: ", Global.map_name)
	Global.map_dsc = map_dsc.get_text()
	Global.new_map = true
	get_tree().change_scene_to_file("res://scenes/processed_game_map.tscn")

func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MapMenu.tscn")
	
func _on_local_only_toggled(toggled_on):
	Global.upload_map = true
	
func _on_privacy_button_item_selected(index):
	if index == 0 and Global.upload_map == true:
		print("private")
		Global.map_privacy = 0
		print("privacy: ", Global.map_privacy)
	if index == 1  and Global.upload_map == true:
		print("public")
		Global.map_privacy = 1
		print("privacy: ", Global.map_privacy)
	
