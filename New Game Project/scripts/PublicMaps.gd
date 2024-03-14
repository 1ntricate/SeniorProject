extends Control

var image_folder_path = "res://player_maps/"
var popup_options = ["Download Map", "UpVote", "DownVote"] 
var map_ids = []
var no_img_icon = "res://no_image.png"
# Called when the node enters the scene tree for the first time.
func _ready():
	$ItemList.icon_mode = ItemList.ICON_MODE_LEFT
	#load_items_into_gallery(image_folder_path)
	Network.connect("pulbic_map_list_ready", Callable(self, "_on_public_list"))
	Network.get_map_list()

func _on_public_list():
	load_map_list()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func load_map_list():
	for map in Global.map_list:
		var map_name = map["MapName"].replace(".tscn", "")
		var map_id = map["MapID"]
		var description = map["Description"]
		var user_name = map["UserName"]
		var upvotes = map["Upvotes"]
		var downvotes = map["Downvotes"]
		var downloads = map["Downloads"]
		var texture
		for thumb in Global.thumb_list:
			print("Checking: ", thumb["filename"], " against ", map_name + '.tscn')
			if thumb["filename"] == map_name+'.tscn':
				print("thumbnail found")
				texture = thumb["texture"]	
		var display_text = "%s (Created By: %s, Upvotes: %d, Downvotes: %d, Downloads: %d)" % [map_name, user_name, upvotes, downvotes,downloads]
		if texture:
			var myVector2i = Vector2i(100, 100)
			texture.set_size_override(myVector2i)
			$ItemList.add_item(display_text,texture)
		else:
			texture = load_image_as_thumbnail(no_img_icon)
			$ItemList.add_item(display_text, texture)
		$ItemList.set_item_tooltip($ItemList.get_item_count() - 1, description)	
		map_ids.append(map_id)

func _on_popup_menu_id_pressed(id):
	# Download map selected
	var selected_index = $ItemList.get_selected_items()[0]
	var map_id = map_ids[selected_index-1]
	if id == 0:
		print("Map ID selected:", map_id)
		Network.download_map(map_id,1)
		#reload()
	# upvote
	if id == 1:
		Network._upvote_map(map_id)
		print("upvoted map")
		reload()
	# downvote
	if id == 2:
		Network._downvote_map(map_id)
		print("downvoted map")
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

func load_image_as_thumbnail(path):
	var image = Image.load_from_file(path) 
	var texture = ImageTexture.create_from_image(image)
	var myVector2i = Vector2i(100, 100)
	texture.set_size_override(myVector2i)
	return texture
	
func reload():
	var scene_tree = get_tree()
	if scene_tree:
		var result = scene_tree.reload_current_scene()
		if result != OK:
			print("Failed to reload the scene.")
	
