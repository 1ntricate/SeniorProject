extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude= FastNoiseLite.new()
var width = 100
var height = 100
@onready var player = get_parent().get_child(2)
var offset_range = 1000
var spawn_pos = Vector2(221.818, -87.2727)
# Elements 
var tree = "Tree"
var grass = "Grass"
var stone = "Stone"
var sand = "Sand"
var sky = "Sky"

func _ready():
	# spawn enemies
	var enemy_scence = "res://scenes/enemy.tscn"
	var enemy = load(enemy_scence)
	for i in range(50):
		var random_offset_x = randf_range(-offset_range, offset_range)
		var random_offset_y = randf_range(-offset_range, offset_range)
		var new_enemy = enemy.instantiate()
		new_enemy.position = spawn_pos + Vector2(random_offset_x, random_offset_y)
		add_child(new_enemy)
	
	if Global.new_map:
		
		var rock_scene = "res://scenes/rock_scene.tscn"
		var tree_scene = "res://scenes/tree_scene.tscn"
		var rock = load(rock_scene)
		var tree = load(tree_scene)
		
		moisture.seed = randi()
		temperature.seed = randi()
		altitude.seed = randi()
		altitude.frequency = 0.005
		
		var elements = Global.elements_identfied
		generate_chunk(player.position, elements)
		# spawn enemies
		
		# spawn elements as objects 
		for i in range (50):
			var random_offset_x = randf_range(-offset_range, offset_range)
			var random_offset_y = randf_range(-offset_range, offset_range)
			if "tree" in elements:
				print("'Tree' was found ")
				var new_tree = tree.instantiate()
				new_tree.set_meta("Saveable",true)
				new_tree.set_meta("type","tree")
				add_child(new_tree)
				new_tree.position =  +spawn_pos + Vector2(random_offset_x, random_offset_y)
			# Check for the word "Rock" in a case-insensitive manner
			if "stone" in elements:
				print("'stone' was found")
				var new_rock = rock.instantiate()
				new_rock.set_meta("Saveable",true)
				new_rock.set_meta("type","rock")
				new_rock.add_to_group("rocks")
				add_child(new_rock)
				new_rock.position =  spawn_pos + Vector2(random_offset_x, random_offset_y)	
		
		call_deferred("save_game")
		Global.new_map = false
	else:
		var current_scene = get_tree().current_scene
		var scene_path = Global.loaded_map
		var json_path = scene_path.replace(".tscn", ".json")
		print("Json path is ", scene_path)
		load_scene_from_file(json_path)
		
var water_tile_1 = Vector2(3,0)
var water_tile_2 = Vector2(3,1)
var grass_tile_1 = Vector2(1,1)
var grass_tile_2 = Vector2(1,2)
var grass_tile_3 = Vector2(2,3)
var sand_tile_1 = Vector2(0,2)
var sand_tile_2 = Vector2(0,3)

func generate_chunk(position,elements):
	var tile_pos = local_to_map(position)
	print(player.position)

	for x in range(width):
		for y in range(height):
			var moist = moisture.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var temp = temperature.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var alt = altitude.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var random = Vector2(round((moist+10)/5),(round((temp+10)/5)))
			#if "tree" in elements:
			set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(round((moist+10)/5),(round((temp+10)/5))))
			#elif "stone" in elements:
			#	set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(round((moist+10)/5),(round((temp+10)/5))))
			#set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(round((moist+10)/5),(round((temp+10)/5))))
			
			#if alt < 2:
			#	set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(3, round((temp+10)/5)))
			#else:
			#	set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(round((moist+10)/5), round((temp+10)/5)))

func save_game():
	var type = ""
	print("Save game called")
	var objects_data = []
	for object in get_children():
		# Using metadata
		if object.has_meta("Saveable"):
			print("saveable")
			if object.get_meta("type") == "tree":
				type = "tree_scene"
			elif object.get_meta("type") == "rock":
				type = "rock_scene"
			var object_dict = {
			"type": type,
			"position": object.position
			}
			objects_data.append(object_dict)
		else:
			print("Not saveable")
	var save_data = {
		"objects": objects_data
	}
	var json = JSON.new()
	var json_data = json.stringify(save_data)
	var j_file_path = "res://player_maps/" +  Global.map_name+ ".json"
	var out_file = FileAccess.open(j_file_path,FileAccess.WRITE)
	if out_file:
		out_file.store_line(json_data)
		
	var file_path = "res://player_maps/" +  Global.map_name+ ".tscn"	
	var current_scene = get_tree().current_scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(current_scene)
	if result == OK:
		var error = ResourceSaver.save(packed_scene, file_path)  # Or "user://..."
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
	

	
func load_scene_from_file(file_path):
	var in_file = FileAccess.open(file_path, FileAccess.READ)
	if in_file:
		var json_text = in_file.get_as_text()
		in_file.close()
		
		var json = JSON.new()
		var error = json.parse(json_text)

		if error == OK:
			var save_data = json.data
			# Spawn objects
			for object_data in save_data["objects"]:
				spawn_object(object_data)
		else:
			print("Failed to parse JSON")
	else:
		print("Failed to open file:", file_path)

func spawn_object(object_data):
	# Assuming object_data["type"] gives a string that corresponds to the resource path
	var resource_path = "res://scenes/" + object_data["type"] + ".tscn"
	var object_scene = load(resource_path) # Use load for runtime-determined paths
	var new_obj = object_scene.instantiate()
	add_child(new_obj)
	var position_string = object_data["position"].replace("(", "").replace(")", "")
	var position_elements = position_string.split(", ")
	var position_vector = Vector2(float(position_elements[0]), float(position_elements[1]))
	new_obj.position = position_vector
	



