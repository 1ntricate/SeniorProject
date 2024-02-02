extends Node2D

var image_folder_path = "res://player_images/"  # Path to the image folder
var selected_image = null
# Called when the node enters the scene tree for the first time.

func _ready():
	load_images_into_gallery(image_folder_path)


func load_texture(path):
	print("load texture called")
	var resource = ResourceLoader.load(path)
	if resource != null and resource is Texture:
		return resource
	return null

func create_image_element(texture):
	var button = TextureButton.new()
	button.texture_normal = texture
	#button.expand = true
	#button.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	button.pressed.connect(self._on_Image_Selected)
	#button.rect_min_size = Vector2(100, 100)
	$ScrollContainer/VBoxContainer.add_child(button)

func _on_Image_Selected():
	# This function will be called when a TextureButton is pressed.
	# 'button' is the TextureButton that was pressed.
	print("Image selected!")
	# Add your code here to handle the image selection.
	
	
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
				var texture = load_texture(image_path)
				if texture:
					create_image_element(texture)
				
	dir.list_dir_end()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
