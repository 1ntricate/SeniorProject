extends Control

var image_folder_path = "user://images/"
var popup_options = ["Process Image", "Delete Image"] # Define your options here

var request_to_filename = {}
var file_name = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	$ItemList.icon_mode = ItemList.ICON_MODE_TOP # Ensure this is set
	load_images_into_gallery(image_folder_path)
	Network._get_images(Global.player_id)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_images_into_gallery(path):
	print("loading images in dir")
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
		var file = "none"
		while file != "":
			print("iterating thru dir")
			file = dir.get_next()
			if !file.begins_with(".") and (file.ends_with(".png") or file.ends_with(".jpg") or file.ends_with(".jpeg")):
				var image_path = path + file
				print(image_path)
				var texture = load_image_as_thumbnail(image_path)
				if texture:
					$ItemList.add_item(file,texture)
				else:
					print("No texture")
					
func load_image_as_thumbnail(path):
	if path != "":
		var image = Image.load_from_file(path) 
		var texture = ImageTexture.create_from_image(image)
		var myVector2i = Vector2i(100, 100)
		if texture != null:
			texture.set_size_override(myVector2i)
		return texture
	return null
var image_paths = []

func _on_popup_menu_id_pressed(id):
	print("id selected: ", id)
	var selected_item = $ItemList.get_selected_items()[0]
	var file_name = $ItemList.get_item_text(selected_item)
	# Handle the selected option here
	print("Option selected for:", file_name, ", Option:", popup_options[id])
	var absolute_path = ProjectSettings.globalize_path("user://images//")
	# process image selected
	if id == 0:
		var path = absolute_path + file_name
		print("Path is ",path)
		Global.selected_image_path = path
		get_tree().change_scene_to_file("res://scenes/process_image.tscn")
	# delete image selected
	if id == 1:
		var dir = DirAccess.open(absolute_path)
		if dir:
			dir.remove(file_name)
			dir.remove(file_name+".import")
			reload()
	
	
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

func reload():
	var scene_tree = get_tree()
	if scene_tree:
		var result = scene_tree.reload_current_scene()
		if result != OK:
			print("Failed to reload the scene.")
	

func _on_file_dialog_file_selected(path):
	var in_file = FileAccess.open(path, FileAccess.READ)
	if in_file:
		var data = in_file.get_buffer(in_file.get_length())
		in_file.close()
		var destination_path = "user://images/"+path.get_file()
		var out_file = FileAccess.open(destination_path,FileAccess.WRITE)
		if out_file:
			out_file.store_buffer(data)
		var base64_data = Marshalls.raw_to_base64(data)
		print("Image added to directory")
		if Global.isUserLoggedIn:
			Network._upload_image(Global.player_id,path.get_file(),base64_data)
		reload()
		
	
