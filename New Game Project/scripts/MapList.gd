extends Control

var image_folder_path = "res://player_maps/"
var popup_options = ["Play Map", "Delete Map Locally","Edit Properties"] # Define your options here
var no_img_icon = "res://no_image.png"
# Called when the node enters the scene tree for the first time.
func _ready():
	$ItemList.icon_mode = ItemList.ICON_MODE_LEFT 
	load_items_into_gallery(image_folder_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_items_into_gallery(path):
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
		var file = "none"
		while file != "":
			file = dir.get_next()
			if !file.begins_with(".") and (file.ends_with(".tscn")):
				var map = file.replace(".tscn", "")
				var j_file = path+map+".json"
				#$ItemList.add_item(map)
				print("map: ",map)
				print("json: ",j_file)
				var in_file = FileAccess.open(j_file, FileAccess.READ)
				if in_file:
					var json_text = in_file.get_as_text()
					in_file.close()
					var json = JSON.new()
					var error = json.parse(json_text)
					if error != OK:
						print("Failed to parse JSON from file:", map+".json")
						return
					var save_data = json.data
					var map_description = save_data["description"]
					var privacy_setting = save_data["privacy"]
					var privacy
					if privacy_setting == 0:
						privacy = "private"
					else :
						privacy = "public"
					var display_text = "%s"% [map]
					var thumbnail = save_data["thumbnail"]
					if thumbnail != null and FileAccess.file_exists(thumbnail):
						var texture = load_image_as_thumbnail(thumbnail)
						if texture:
							var myVector2i = Vector2i(100, 100)
							texture.set_size_override(myVector2i)
							$ItemList.add_item(display_text, texture)
					else:
						var texture = load_image_as_thumbnail(no_img_icon)
						if texture:
							var myVector2i = Vector2i(100, 100)
							texture.set_size_override(myVector2i)
							$ItemList.add_item(display_text,texture)
					$ItemList.set_item_tooltip($ItemList.get_item_count() - 1, map_description)	
				else:
					print("error opening json")
					

func load_image_as_thumbnail(path):
	var image = Image.load_from_file(path) 
	var texture = ImageTexture.create_from_image(image)
	var myVector2i = Vector2i(100, 100)
	texture.set_size_override(myVector2i)
	return texture
	
var image_paths = []

func _on_popup_menu_id_pressed(id):
	print("id selected: ", id)
	var selected_item = $ItemList.get_selected_items()[0]
	var file_name = $ItemList.get_item_text(selected_item)
	# Handle the selected option here
	print("Option selected for:", file_name, ", Option:", popup_options[id])
	var absolute_path = ProjectSettings.globalize_path("res://") + "/player_maps/"
	# process image selected
	if id == 0:
		var path = absolute_path + file_name + ".tscn"
		Global.loaded_map = path
		print("map path is: ", path)
		get_tree().change_scene_to_file(path)
	# delete image selected
	if id == 1:
		var dir = DirAccess.open(absolute_path)
		if dir:
			dir.remove(file_name+".tscn")
			dir.remove(file_name+".json")
			reload()
	if id ==2:
		var path = absolute_path + file_name + ".json"
		Global.selected_map = file_name
		Global.selected_map_path = path
		get_tree().change_scene_to_file("res://scenes/Map_editor.tscn")
		
func reload():
	var scene_tree = get_tree()
	if scene_tree:
		var result = scene_tree.reload_current_scene()
		if result != OK:
			print("Failed to reload the scene.")
	
	
func _on_item_list_item_selected(index):
	$PopupMenu.clear()
	for option in popup_options:
		$PopupMenu.add_item(option)
		$PopupMenu.popup() # Show the popup at the current mouse position.

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	
func _on_new_image_button_pressed():
	$FileDialog.popup()
	pass # Replace with function body.


