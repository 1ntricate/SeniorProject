extends Control

@onready var map_name = get_node("%MapName")
@onready var map_dsc = get_node("%MapDescription")
@onready var dsc_box = $MainMapContainer/MapDescription
@onready var map_name_box = $MainMapContainer/MapName
@onready var player = $PlayerName
var image_folder_path = "res://player_screenshots/"
var popup_options = ["Use as Thumbnail", "Delete Image"] # Define your options here

var player_label
var new_name = null
var new_dsc = null
var old_privacy = null
var new_privacy = null
var new_thumbnail = null
var cur_thumbnail = null
var on_server = false
var prev_setting
var path1
var path2
var scene_data
var json_data
var map_id = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Network.connect("map_uploaded", Callable(self,"_on_map_uploaded"))
	Network.connect("map_removed", Callable(self, "_on_map_removed"))
	Network.connect("map_updated", Callable(self, "_on_map_updated"))
	print("map name: ", Global.selected_map)
	map_name_box.text = Global.selected_map
	get_map_info()
	prev_setting = on_server
	$ItemList.icon_mode = ItemList.ICON_MODE_TOP # Ensure this is set
	load_images_into_gallery(image_folder_path)
	if player:
		player.text = "Created By: "
	else:
		print("Label node not found")	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_map_info():
	print("selected map: ", Global.selected_map_path)
	var in_file = FileAccess.open(Global.selected_map_path, FileAccess.READ)
	if in_file:
		var json_text = in_file.get_as_text()
		in_file.close()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error != OK:
			print("Failed to parse JSON")
			return
		var save_data = json.data
		var created_by = save_data["created_by"]
		var thumb_nail = save_data["thumbnail"]
		if thumb_nail != null:
			cur_thumbnail = thumb_nail
		#if created_by != null:
		#	player_label.text = "Created By: "
		var map_description = save_data["description"]
		var map__id = int(save_data["map_id"])
		print("MapID: ", map_id)
		if map__id != 0:
			map_id = map__id
			print("Map on server")
			$OnServer.button_pressed = true
			on_server = true
		dsc_box.text = map_description
		var privacy_setting = save_data["privacy"]
		if privacy_setting == null:
			privacy_setting = 0
		old_privacy = privacy_setting
		print("Priacy:", privacy_setting)
		$PrivacyButton.select(privacy_setting)
		
	else:
		print("error opening json")
		
func _on_save_button_pressed():
	new_name = map_name.get_text()
	new_dsc = map_dsc.get_text()
	update_json()
	check_on_server()
	reload()
	
func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MapMenu.tscn")

# toggle OnServer checkbox
func _on_local_only_toggled(toggled_on):
	on_server = !on_server

# get map privacy setting selected
func _on_privacy_button_item_selected(index):
	if index == 0:
		print("private")
		new_privacy = 0
	if index == 1:
		print("public")
		new_privacy = 1
		
# update map info
func update_json():
	var in_file = FileAccess.open(Global.selected_map_path, FileAccess.READ)
	if in_file:
		var json_text = in_file.get_as_text()
		in_file.close()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error != OK:
			print("Failed to parse JSON")
			return
		var save_data = json.data
		save_data["description"] = new_dsc
		if new_privacy != null:
			save_data["privacy"] = new_privacy
		if new_thumbnail !=null:
			save_data["thumbnail"] = new_thumbnail
		var json_data = json.stringify(save_data)
		var out_file = FileAccess.open(Global.selected_map_path,FileAccess.WRITE)
		path1 = Global.selected_map_path #json path
		path2 = Global.selected_map_path.replace(".json",".tscn") # map path
		
		# update map info
		if out_file:
			out_file.store_line(json_data)
			print("updated json")
			# rename map
			if new_name != null:
				var dir = Global.selected_map_path.get_base_dir() + "/"
				var old_json_path = Global.selected_map_path.get_file()
				var old_map_path = old_json_path.replace(".json", ".tscn")
				var new_json_path = dir + new_name + ".json"
				var new_map_path = dir + new_name+  ".tscn"
				print("new_map_path: ", new_map_path)
				path1 = new_json_path
				path2 = new_map_path
				rename_files(Global.selected_map_path, new_json_path)
				rename_files(old_map_path, new_map_path)
		print("path1: ", path1)
		print("path2: ", path2)
	else:
		print("error updating map")

# rename map if user updated name
func rename_files(old_path,new_path):
	var dir_access = DirAccess.open("res://player_maps/")
	if dir_access:
		var result = dir_access.rename(old_path, new_path)
		if result == OK:
			print("File renamed successfully.")
		else:
			print("Failed to rename file.")

# check if map was on server and if user wishes to upload or remove from server
func check_on_server():
	if on_server == true and prev_setting == false:
		print("Uploading Map to Server")
		upload_map()
	if on_server == false and prev_setting == true:
		if Global.player_id !=99999 and map_id != null:
			print("Removing Map from server")
			Network._remove_map(Global.player_id, map_id)
			
	if on_server == true and prev_setting == true:
		print("Updating Map on server")
		print("thumbnail: ", new_thumbnail)
		var paths_data = prepare_paths()
		var scene_data = paths_data[0]  
		var json_data = paths_data[1]  
		var privacy = paths_data[2]
		var result = prepare_thumbnail()
		var base64_data = result[0]  
		var filename = result[1]  
		Network._update_map(Global.player_id, map_id,scene_data,json_data, new_name,privacy,new_dsc,base64_data,filename)

# upload map to server
func upload_map():
	print("Upload map called")
	var paths_data = prepare_paths()
	var scene_data = paths_data[0]  
	var json_data = paths_data[1]  
	var privacy = paths_data[2]
	var result = prepare_thumbnail()
	var base64_data = result[0]  
	var filename = result[1]  
	Network._upload_map(Global.player_id, scene_data,json_data, new_name,privacy, new_dsc,base64_data,filename)

'''
var json = JSON.new()
	var json_data = json.stringify(save_data)
	var j_file_path = "res://player_maps/" +  Global.map_name+ ".json"
	var out_file = FileAccess.open(j_file_path,FileAccess.WRITE)
	if out_file:
		out_file.store_line(json_data)
'''

# helper function
func prepare_paths():
	var scene_file = FileAccess.open(path2, FileAccess.READ)
	if scene_file:
		scene_data = scene_file.get_as_text()
		scene_file.close()
		
	var json_file = FileAccess.open(path1, FileAccess.READ)
	print("Path1 from prepare_paths: ",path1)
	if json_file:
		var json_text = json_file.get_as_text()
		json_file.close()
		var json = JSON.new()
		var json_result = json.parse(json_text)
		if json_result == OK:
			json_data = json.data
			# Now 'json_data' contains the parsed JSON data as a GDScript object (Dictionary or Array)
			print("Loaded JSON data: ", json_data)
		else:
			print("Failed to parse JSON data: ", json_result.error_string)
			
	var privacy
	if new_privacy == null:
		privacy = old_privacy
	else:
		privacy = new_privacy
	return [scene_data,json_data,privacy]

func prepare_thumbnail():
	var data
	var base64_data
	if new_thumbnail != null:
		var filename = new_thumbnail.get_file() 
		print("thumbnail path: ", new_thumbnail)
		var in_file = FileAccess.open(new_thumbnail, FileAccess.READ)
		if in_file:
			data = in_file.get_buffer(in_file.get_length())
			in_file.close()
			base64_data = Marshalls.raw_to_base64(data)
			return [base64_data,filename]
	else:
		print("returning null & null")
		return [null,null]
# for newly uploaded maps, update local json file with the new mapID
func _on_map_uploaded():
	print("map uploaded")
	var json_path = "res://player_maps/" +  Global.map_name+ ".json"
	var in_file = FileAccess.open(path1, FileAccess.READ)
	if in_file:
		var json_text = in_file.get_as_text()
		in_file.close()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error != OK:
			print("Failed to parse JSON")
			return
		var save_data = json.data
		save_data["map_id"] = Global.uploaded_map_id
		var json_data = json.stringify(save_data)
		var out_file = FileAccess.open(path1,FileAccess.WRITE)
		if out_file:
			out_file.store_line(json_data)
			print("Added MapID to json")
			get_tree().change_scene_to_file("res://scenes/MapMenu.tscn")
			
# remove map_id from JSON file after map has been removed from server
func _on_map_removed():
	print("Map removed from server")
	var in_file = FileAccess.open(path1, FileAccess.READ)
	if in_file:
		var json_text = in_file.get_as_text()
		in_file.close()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error != OK:
			print("Failed to parse JSON")
			return
		var save_data = json.data
		save_data["map_id"] = 0
		var json_data = json.stringify(save_data)
		var out_file = FileAccess.open(path1,FileAccess.WRITE)
		if out_file:
			out_file.store_line(json_data)
			print("MapID removed from Json")
			

func _on_map_updated():
	print("Map updated on Server")


func _on_item_list_item_selected(index):
	$PopupMenu.clear()
	for option in popup_options:
		$PopupMenu.add_item(option)
		$PopupMenu.popup() # Show the popup at the current mouse position.


func _on_popup_menu_id_pressed(id):
	print("id selected: ", id)
	var selected_item = $ItemList.get_selected_items()[0]
	var file_name = $ItemList.get_item_text(selected_item)
	# Handle the selected option here
	print("Option selected for:", file_name, ", Option:", popup_options[id])
	var absolute_path = "res://player_screenshots/"
	# use as thumbnail selected
	if id == 0:
		var path = absolute_path + file_name
		print("Path is ",path)
		new_thumbnail = path
		print("new thumbnail: ", path)
	# delete image selected
	if id == 1:
		var dir = DirAccess.open(absolute_path)
		if dir:
			dir.remove(file_name)
			dir.remove(file_name+".import")
			reload()
	
'''
dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if !file_name.begins_with(".") and file_name.find(filename_without_extension) != -1:
			ssCount += 1
		file_name = dir.get_next()
	dir.list_dir_end()
'''
func load_images_into_gallery(path):
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()
		var file = "none"
		while file != "":
			file = dir.get_next()
			if !file.begins_with(".") and (file.ends_with(".png") or file.ends_with(".jpg") or file.ends_with(".jpeg")) and file.find(Global.selected_map) != -1:
				var image_path = path + file
				print(image_path)
				var texture = load_image_as_thumbnail(image_path)
				if texture:
					var item_index = $ItemList.add_item(file, texture)
					if cur_thumbnail !=null and cur_thumbnail == image_path:
						#Sets the background color of the item specified by idx index to the specified Color.
						$ItemList.set_item_custom_bg_color(item_index,Color(0.5, 0.42, 0, 0.5))
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

func reload():
	var scene_tree = get_tree()
	if scene_tree:
		var result = scene_tree.reload_current_scene()
		if result != OK:
			print("Failed to reload the scene.")
	
