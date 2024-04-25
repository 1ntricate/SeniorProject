extends Node

var content : Dictionary

func _ready():
	var file = FileAccess.open("res://scenes/inventory/inventory_item_db/inventory_db.json", FileAccess.READ)
	
	content = JSON.parse_string((file.get_as_text()))
	
	file.close()
	
func get_texture(ID = "0"):
	return content[ID]["texture"]

func get_ATK(ID = "0"):
	return content[ID]["ATK"]

func get_slot_type(ID = "0"):
	return content[ID]["slot_type"]
	
func get_w_name(ID = "0"):
	return content[ID]["w_name"]
