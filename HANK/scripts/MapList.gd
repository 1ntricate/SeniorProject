extends Control

var image_folder_path = "user://maps/"
var popup_options = ["Play Map", "Delete Map Locally","Edit Properties"] # Define your options here
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
		var file = dir.get_next()
		while file != "":
			if !file.begins_with(".") and file.ends_with(".tscn"):
				var map = file.replace(".tscn", "")
				var j_file = path + map + ".json"
				print("map: ", map)
				print("json: ", j_file)
				
				var in_file = FileAccess.open(j_file, FileAccess.READ)
				if in_file:
					var json_text = in_file.get_as_text()
					in_file.close()
					
					var json = JSON.new()
					var error = json.parse(json_text)
					if error != OK:
						print("Failed to parse JSON from file:", map + ".json")
						continue  # Skip this iteration
					
					var save_data = json.get_data()
					
					# Check for each required entry in JSON and handle if not present
					var map_description = save_data.get("description", "No description provided.")
					var map_id = save_data.get("map_id", 0)
					var privacy_setting = save_data.get("privacy", 0)  # Default to private if not specified
					var privacy = "public" if privacy_setting != 0 else "private"
					var thumbnail = save_data.get("thumbnail", null)

					var display_text = "%s" % [map]
					var texture_path = thumbnail if thumbnail != null and FileAccess.file_exists(thumbnail) else "user://no_image_icon.png"
					var texture = load_image_as_thumbnail(texture_path)
					
					if texture:
						texture.set_size_override(Vector2i(100, 100))
						$ItemList.add_item(display_text, texture)
						$ItemList.set_item_metadata($ItemList.get_item_count() - 1, map_id)
					
					$ItemList.set_item_tooltip($ItemList.get_item_count() - 1, map_description)
				else:
					print("Error opening JSON file: ", j_file)
			file = dir.get_next()
		dir.list_dir_end()

					

func load_image_as_thumbnail(path):
	var image = Image.load_from_file(path) 
	var texture = ImageTexture.create_from_image(image)
	var myVector2i = Vector2i(100, 100)
	if texture:
		texture.set_size_override(myVector2i)
		return texture
	else:
		return null
	
var image_paths = []

func _on_popup_menu_id_pressed(id):
	print("id selected: ", id)
	var selected_item = $ItemList.get_selected_items()[0]
	var file_name = $ItemList.get_item_text(selected_item)
	var map_id = $ItemList.get_item_metadata(selected_item)
	print("Map ID: ", map_id)
	if map_id !=null:
		Global.last_played_map_id = int($ItemList.get_item_metadata(selected_item))
	# Handle the selected option here
	print("Option selected for:", file_name, ", Option:", popup_options[id])
	var absolute_path = ProjectSettings.globalize_path("user://") + "/maps/"

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
	get_tree().change_scene_to_file("res://scenes/map_selector.tscn")
	
func _on_new_image_button_pressed():
	$FileDialog.popup()
	pass # Replace with function body.


