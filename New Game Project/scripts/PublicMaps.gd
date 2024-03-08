extends Control

var image_folder_path = "res://player_maps/"
var popup_options = ["Download Map", "UpVote", "DownVote"] 
var map_ids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$ItemList.icon_mode = ItemList.ICON_MODE_TOP 
	#load_items_into_gallery(image_folder_path)
	Network.connect("map_list_received", Callable(self, "_on_map_list_received"))
	Network.get_map_list()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_map_list_received():
	print("List received: ", Global.map_list)
	load_map_list()

func load_map_list():
	for map in Global.map_list:
		var map_name = map["MapName"].replace(".tscn", "")
		var map_id = map["MapID"]
		var description = map["Description"]
		var user_name = map["UserName"]
		var upvotes = map["Upvotes"]
		var downvotes = map["Downvotes"]
		var display_text = "%s (Created By: %s, Upvotes: %d, Downvotes: %d)" % [map_name, user_name, upvotes, downvotes]
		$ItemList.add_item(display_text)
		$ItemList.set_item_tooltip($ItemList.get_item_count() - 1, description)	
		map_ids.append(map_id)

func _on_popup_menu_id_pressed(id):
	var selected_index = $ItemList.get_selected_items()[0]
	var map_id = map_ids[selected_index-1]
	print("Map ID selected:", map_id)
	Network.download_map(map_id,1)
	
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


