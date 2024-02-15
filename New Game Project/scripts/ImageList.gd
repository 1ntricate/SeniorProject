extends Control

var image_folder_path = "res://player_images/"
var popup_options = ["Process Image"] # Define your options here

var request_to_filename = {}

var file_name = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	$ItemList.icon_mode = ItemList.ICON_MODE_TOP # Ensure this is set
	load_images_into_gallery(image_folder_path)
	Network.connect("images_received", Callable(self, "_on_images_received"))
	Network._get_images(3)

func _on_images_received():
	_setup_requests(Global.image_urls)

func _setup_requests(urls):
	print(urls)
	for link in urls:
		var image_url = link["url"]
		#var filename = url["filename"]
		file_name = link["filename"]
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(self._http_request_completed)
		#request_to_filename[http_request] = filename 
		var error = http_request.request(image_url)
		
			
func _http_request_completed(result, response_code, headers, body):
	var save_path = "res://player_images/"
	if result == HTTPRequest.RESULT_SUCCESS:
		#var filer_namme = 
		var image_name =  file_name  + ".png"
		var full_save_path = save_path + image_name
		var out_file = FileAccess.open(full_save_path, FileAccess.WRITE)
		#var filer_name = request_to_filename[http_request]
		if out_file:
			out_file.store_buffer(body)
			out_file.close()
			print("Image added to directory")	
	
func _generate_random_string(length: int) -> String:
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	var random_string = ""
	for i in length: # Note: In Godot 4.2, use '..' for inclusive range
		var index = randi() % characters.length()
		random_string += characters[index]
	return random_string	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_images_into_gallery(path):
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
		var file = "none"
		while file != "":
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

func load_images_from_directory(path):
	print("load images called")
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
				image_paths.append("res://images/" + file)  # Store file paths as constant strings
		dir.list_dir_end()
	return null

func _on_popup_menu_id_pressed(id):
	var selected_item = $ItemList.get_selected_items()[0]
	var file_name = $ItemList.get_item_text(selected_item)
	# Handle the selected option here
	print("Option selected for:", file_name, ", Option:", popup_options[id])
	var absolute_path = ProjectSettings.globalize_path("res://")
	print("psth ",absolute_path)
	var path = absolute_path + "/player_images/" + file_name
	print("Path is ",path)
	Global.selected_image_path = path
	
	get_tree().change_scene_to_file("res://scenes/process_image.tscn")
	
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
		Network._upload_image(Global.player_id,path.get_file(),data)
		
	var scene_tree = get_tree()
	if scene_tree:
		var result = scene_tree.reload_current_scene()
		if result != OK:
			print("Failed to reload the scene.")
