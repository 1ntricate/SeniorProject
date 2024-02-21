extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$FileDialog.popup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func _on_file_dialog_file_selected(path):
		
	Global.selected_image_path = path
	var image = Image.new()
	var load_error = image.load(path)
	
	if load_error != OK:
		print("Error loading image:", load_error)
	else:
		print("Image loaded successfully:", path)
		var texture = ImageTexture.create_from_image(image)
		texture.create_from_image(image)
		$Sprite2D.texture = texture
		# Set the desired size of the displayed image
		var desired_size = Vector2(150, 100)  # Adjust the size as needed
		$Sprite2D.scale = desired_size / texture.get_size()
		print("Texture created")
		$Timer.start()

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
			elif not file.begins_with(".") and (file.ends_with(".png") or file.ends_with(".jpg") or file.ends_with(".jpeg")):
				image_paths.append("res://images/" + file)  # Store file paths as constant strings
		dir.list_dir_end()
	return null

func load_texture(path):
	print("load texture called")
	var resource = ResourceLoader.load(path)
	if resource != null and resource is Texture:
		return resource
	return null


func _on_timer_timeout():
	$Sprite2D.texture = null
	get_tree().change_scene_to_file("res://scenes/process_image.tscn")


func _on_file_dialog_canceled():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	
