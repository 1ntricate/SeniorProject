extends Control

@onready var map_name = get_node("%MapName")
@onready var map_dsc = get_node("%MapDescription")

@onready var text_box = $TextEdit
@onready var dsc_box = $MainMapContainer/MapDescription
@onready var map_name_box = $MainMapContainer/MapName
var new_name = null
var new_dsc = null
var old_privacy = null
var new_privacy = null
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
	text_box.text = "Elements Identified"
	var elements = Global.elements_identfied
	text_box.text = elements
	print("map name: ", Global.selected_map)
	map_name_box.text = Global.selected_map
	get_map_info()
	prev_setting = on_server
	
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
		var desc = save_data["description"]
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
		var paths_data = prepare_paths()
		var scene_data = paths_data[0]  
		var json_data = paths_data[1]  
		var privacy = paths_data[2]
		Network._update_map(Global.player_id, map_id,scene_data,json_data, new_name,privacy,new_dsc)
		#func _update_map(PlayerID, MapID,scene,position_data, file_name,privacy,description):
# upload map to server
func upload_map():
	var paths_data = prepare_paths()
	var scene_data = paths_data[0]  
	var json_data = paths_data[1]  
	var privacy = paths_data[2]
	Network._upload_map(Global.player_id, scene_data,json_data, new_name,privacy, new_dsc)

# helper function
func prepare_paths():
	var scene_file = FileAccess.open(path2, FileAccess.READ)
	if scene_file:
		scene_data = scene_file.get_as_text()
		scene_file.close()
		
	var json_file = FileAccess.open(path1, FileAccess.READ)
	if json_file:
		json_data = scene_file.get_as_text()
		json_file.close()
		
	var privacy
	if new_privacy == null:
		privacy = old_privacy
	else:
		privacy = new_privacy
	return [scene_data,json_data,privacy]

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
