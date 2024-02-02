extends Control

var image_folder_path = "res://player_images/"
var popup_options = ["Delete", "Rename", "Option 3"] # Define your options here

# Called when the node enters the scene tree for the first time.
func _ready():
	$ItemList.icon_mode = ItemList.ICON_MODE_TOP # Ensure this is set
	load_images_into_gallery(image_folder_path)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_images_into_gallery(path):
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
		var file_name = "none"
		while file_name != "":
			file_name = dir.get_next()
			if !file_name.begins_with(".") and file_name.ends_with(".png"):
				var image_path = path + file_name
				print(image_path)
				var texture = load_image_as_thumbnail(image_path)
				if texture:
					$ItemList.add_item(file_name,texture)
				else:
					print("No texture")
					
func load_image_as_thumbnail(path):
	var image = Image.load_from_file(path) 
	var texture = ImageTexture.create_from_image(image)
	var myVector2i = Vector2i(100, 100)
	texture.set_size_override(myVector2i)
	return texture
	
var image_paths = []

func load_images_from_directory(path):
	print("load images called")
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with(".") and file.ends_with(".png"):
				image_paths.append("res://images/" + file)  # Store file paths as constant strings
		dir.list_dir_end()
	return null

func _on_popup_menu_id_pressed(id):
	var selected_item = $ItemList.get_selected_items()[0]
	var file_name = $ItemList.get_item_text(selected_item)
	# Handle the selected option here
	print("Option selected for:", file_name, ", Option:", popup_options[id])
	
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


func _on_file_dialog_file_selected(path):
	var in_file = FileAccess.open(path, FileAccess.READ)
	if in_file:
		var data = in_file.get_buffer(in_file.get_length())
		in_file.close()
		var destination_path = "res://player_images/"+path.get_file()
		var out_file = FileAccess.open(destination_path,FileAccess.WRITE)
		if out_file:
			out_file.store_buffer(data)
		print("Image added to directory")
		
	var scene_tree = get_tree()
	if scene_tree:
		var result = scene_tree.reload_current_scene()
		if result != OK:
			print("Failed to reload the scene.")
