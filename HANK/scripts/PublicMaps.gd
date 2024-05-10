extends Control

var image_folder_path = "user://maps/"
var popup_options = ["Download Map", "UpVote", "DownVote", "Rate Difficulty"] 
var map_ids = []
var no_img_icon = "user://no_image.png"
var rating_set = false
var max_stars = 5
var current_rating = 0
var final_rating = 0
var current_map_id = null
var prev_map_id = null
var cur_map = ""
var empty_star_texture = load("res://empty_star.png")
var half_star_texture = load("res://half_star.png")
var full_star_texture = load("res://star.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$ItemList.icon_mode = ItemList.ICON_MODE_LEFT
	
	#load_items_into_gallery(image_folder_path)
	Network.connect("pulbic_map_list_ready", Callable(self, "_on_public_list"))
	Network.get_map_list(0)
	

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
		var diff = map["Difficulty"]
		var texture
		var display_text
		for thumb in Global.thumb_list:
			#print("Checking: ", thumb["filename"], " against ", map_name + '.tscn')
			if thumb["filename"] == map_name+'.tscn':
				#print("thumbnail found")
				texture = thumb["texture"]
				break
		if diff != null:
			display_text = "%s (Created By: %s, Upvotes: %d, Downvotes: %d, Downloads: %d, Difficulty: %.2f )" % [map_name, user_name, upvotes, downvotes,downloads, diff]
		else:
			display_text = "%s (Created By: %s, Upvotes: %d, Downvotes: %d, Downloads: %d)" % [map_name, user_name, upvotes, downvotes,downloads]
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
	cur_map = Global.map_list[selected_index-1]["MapName"].replace(".tscn", "")
	current_map_id = map_id
	if id == 0:
		print("Map ID selected:", map_id)
		Network.download_map(map_id,1)
		#reload()
	# upvote
	if id == 1:
		Network._vote_map(map_id,Global.player_id,"upvote")
		print("upvoted map")
		reload()
	# downvote
	if id == 2:
		Network._vote_map(map_id,Global.player_id,"downvote")
		print("downvoted map")
		reload()
	# rate difficulty	
	if id == 3:
		#PlayContainer.visible = true
		%Control.visible = true
		#$Control.position = 
		pass
		
	
func _on_item_list_item_selected(index):
	$PopupMenu.clear()
	var item_height = 100  # Example item height, adjust based on your UI
	var list_scroll_offset = $ItemList.get_v_scroll_bar().value
	var item_y_position = index * item_height - list_scroll_offset
	var control_x_position = 31
	var control_y_position = (index + 1) * 100.0
	
	$Control.set_position(Vector2(31,control_y_position))
	for option in popup_options:
		$PopupMenu.add_item(option)
		$PopupMenu.popup() # Show the popup at the current mouse position.

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/map_selector.tscn")
	
func _on_new_image_button_pressed():
	$FileDialog.popup()
	pass # Replace with function body.

func load_image_as_thumbnail(path):
	var image = Image.load_from_file(path) 
	var texture = ImageTexture.create_from_image(image)
	var myVector2i = Vector2i(100, 100)
	if texture:
		texture.set_size_override(myVector2i)
	return texture


func reload():
	var scene_tree = get_tree()
	if scene_tree:
		var result = scene_tree.reload_current_scene()
		if result != OK:
			print("Failed to reload the scene.")
	


func _on_option_button_item_selected(index):
	# sort by downloads
	Global.map_list = []
	Global.thumb_list = []
	$ItemList.clear()
	if index == 0:
		Network.get_map_list(0)
		pass
	# sort by difficulty
	if index == 1:
		Network.get_map_list(1)
		pass
	# sort by New
	if index == 2:
		Network.get_map_list(2)
		pass
	# sort by Upvotes
	if index == 3:
		Network.get_map_list(3)
		pass
	# sort by downvotes
	if index == 4:
		Network.get_map_list(4)
		pass
	

func _on_star_1_mouse_entered():
	if !rating_set:
		%Control/Star1.texture_normal = full_star_texture

func _on_star_2_mouse_entered():
	if !rating_set:
		%Control/Star1.texture_normal = full_star_texture
		%Control/Star2.texture_normal = full_star_texture

func _on_star_3_mouse_entered():
	if !rating_set:
		%Control/Star1.texture_normal = full_star_texture
		%Control/Star2.texture_normal = full_star_texture
		%Control/Star3.texture_normal = full_star_texture

func _on_star_4_mouse_entered():
	if !rating_set:
		%Control/Star1.texture_normal = full_star_texture
		%Control/Star2.texture_normal = full_star_texture
		%Control/Star3.texture_normal = full_star_texture
		%Control/Star4.texture_normal = full_star_texture

func _on_star_5_mouse_entered():
	if !rating_set:
		%Control/Star1.texture_normal = full_star_texture
		%Control/Star2.texture_normal = full_star_texture
		%Control/Star3.texture_normal = full_star_texture
		%Control/Star4.texture_normal = full_star_texture
		%Control/Star5.texture_normal = full_star_texture

func _on_control_mouse_exited():
	if !rating_set:
		%Control/Star1.texture_normal = empty_star_texture
		%Control/Star2.texture_normal = empty_star_texture
		%Control/Star3.texture_normal = empty_star_texture
		%Control/Star4.texture_normal = empty_star_texture
		%Control/Star5.texture_normal = empty_star_texture
	if current_map_id != prev_map_id:
		%Control.visible = false
		
func _on_star_1_mouse_exited():
	if !rating_set:
		%Control/Star1.texture_normal = empty_star_texture

func _on_star_2_mouse_exited():
	if !rating_set:
		%Control/Star2.texture_normal = empty_star_texture
	
func _on_star_3_mouse_exited():
	if !rating_set:
		%Control/Star3.texture_normal = empty_star_texture

func _on_star_4_mouse_exited():
	if !rating_set:
		%Control/Star4.texture_normal = empty_star_texture
	
func _on_star_5_mouse_exited():
	if !rating_set:
		%Control/Star5.texture_normal = empty_star_texture

func _on_confirm_rating_button_pressed():
	final_rating = current_rating
	rating_set = false
	Network._rate_map_difficulty(Global.player_id,current_map_id, final_rating)
	%Control/ConfirmRatingButton.hide()
	%Control/CancelRatingButton.hide()
	%Control/ConfrimLabel.hide()

func _on_cancel_rating_button_pressed():
	rating_set = false
	current_rating = 0
	%Control/ConfirmRatingButton.hide()
	%Control/CancelRatingButton.hide()
	%Control/ConfrimLabel.hide()
	
func _on_star_1_gui_input(event):
	if event is InputEventMouseButton:
		check_input(event,1)

func _on_star_2_gui_input(event):
	if event is InputEventMouseButton:
		check_input(event,2)

func _on_star_3_gui_input(event):
	if event is InputEventMouseButton:
		check_input(event,3)
			

func _on_star_4_gui_input(event):
	if event is InputEventMouseButton:
		check_input(event,4)
			
func _on_star_5_gui_input(event):
	if event is InputEventMouseButton:
		check_input(event,5)
		
func check_input(event,rating):
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		rating_set = true
		current_rating = rating
		%Control/ConfirmRatingButton.show()
		%Control/CancelRatingButton.show()
		%Control/ConfrimLabel.text = "Confirm " + str(current_rating) +" star rating for " + str(cur_map) + "?"
		%Control/ConfrimLabel.show()
	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		rating_set = true
		current_rating = (rating - 0.5)
		var node_path = "%Control/Star" +str(rating)
		print("start node: ", node_path)
		var star_node = get_node(node_path)
		star_node.texture_normal = half_star_texture
		%Control/ConfirmRatingButton.show()
		%Control/CancelRatingButton.show()
		%Control/ConfrimLabel.text = "Confirm " + str(current_rating) +" star rating for " + str(cur_map) + "?"
		%Control/ConfrimLabel.show()
		


func _on_control_mouse_entered():
	prev_map_id = current_map_id
	
