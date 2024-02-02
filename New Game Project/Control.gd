extends Control

var imageFolder = "res://player_images/"
var gridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	gridContainer = $GridContainer
	var dir = DirAccess.open(imageFolder)
	if dir != null:
		while dir.get_next() != null:
			if dir.current_is_dir() == false:
				var texture = load(imageFolder + dir.get_file())
				if texture:
					var imageButton = TextureButton.new()
					imageButton.texture_normal = texture
					imageButton.rect_min_size = Vector2(100, 100)  # Adjust the size as needed
					#imageButton.connect("pressed", self, "_on_image_button_pressed", texture, dir.get_file())
					#gridContainer.add_child(imageButton)
	dir.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_grid_container_child_entered_tree(node):
	pass # Replace with function body.
