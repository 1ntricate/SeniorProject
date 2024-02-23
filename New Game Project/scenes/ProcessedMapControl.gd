extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude= FastNoiseLite.new()
var width = 500
var height = 500
@onready var player = get_parent().get_child(2)
var offset_range = 1800
var spawn_pos = Vector2(221.818, -87.2727)
var elements = Global.elements_identfied
var monster_count = 20
var resoruce_objects_count = 15
var enemey_offset_range = 800

var chosen_tile = null
'''
var max_temp = 0
var min_temp = 999
var max_moist = 0
var min_moist = 999
var max_alt = 0
var min_alt = 999
'''
# tile coordinates
var water_tile_1 = Vector2(3,0)
var water_tile_2 = Vector2(3,1)
var water_tile_3 = Vector2(3,2)
var water_tile_4 = Vector2(3,3)

var grass_tile_1 = Vector2(1,1)
var grass_tile_2 = Vector2(2,1)
var grass_tile_3 = Vector2(1,2)
var grass_tile_4 = Vector2(2,2)
var grass_tile_5 = Vector2(2,3)

var sand_tile_1 = Vector2(0,2)
var sand_tile_2 = Vector2(0,3)
var sand_tile_3 = Vector2(1,3)

var steel_tile = Vector2(2,0)



func _ready():
	# spawn enemies
	var slime_scence = "res://scenes/enemy.tscn"
	var skeleton_scene = "res://scenes/skeleton.tscn"
	var goblin_scene = "res://scenes/goblin.tscn"
	var spider_scene = "res://scenes/spider.tscn"
	var rock_scene = "res://scenes/rock_scene.tscn"
	var tree_scene = "res://scenes/tree_scene.tscn"
	var slime = load(slime_scence)
	var skeleton = load(skeleton_scene)
	var spider = load(spider_scene)
	var goblin = load(goblin_scene)
	var rock = load(rock_scene)
	var tree = load(tree_scene)

	

	# Spawn seperately to ensure unqique spawn positions
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_slime = slime.instantiate()
		add_child(new_slime)
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_slime.position = spawn_pos + Vector2(random_offset_x, random_offset_y)
		
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_skeleton = skeleton.instantiate()
		add_child(new_skeleton)
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_skeleton.position =  spawn_pos + Vector2(random_offset_x, random_offset_y)
	
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_spider = spider.instantiate()
		add_child(new_spider)
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_spider.position =  spawn_pos + Vector2(random_offset_x*2, random_offset_y*2)
		
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_goblin = goblin.instantiate()
		add_child(new_goblin)
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_goblin.position =  -spawn_pos + Vector2(random_offset_x, random_offset_y)
		
	# if creating new map
	if Global.new_map:
		moisture.seed = randi()
		temperature.seed = randi()
		altitude.seed = randi()
		altitude.frequency = 0.005
		generate_chunk(player.position, elements)
		# spawn elements as objects 
		for i in range (50):
			var random_offset_x = randf_range(-offset_range, offset_range)
			var random_offset_y = randf_range(-offset_range, offset_range)
			if "tree" in elements or "grass" in elements and Global.grass_coordinates.keys():
				var keys = Global.grass_coordinates.keys()
  				  # Check if the dictionary is not empty to avoid errors
				if keys.size() > 0:
					# Randomly select an index from the keys array
					var random_index = randi() % keys.size()
					# Retrieve the key (coordinate string) at the randomly selected index
					var coord_key = keys[random_index]
	   		 		# Split the key back into its original x, y components
					var coords = coord_key.split(",")
					var x = int(coords[0])
					var y = int(coords[1])
					var grass_vect = Vector2(x,y)
					var new_tree = tree.instantiate()
					new_tree.set_meta("Saveable",true)
					new_tree.set_meta("type","tree")
					add_child(new_tree)
					new_tree.position = grass_vect
					
			if "stone" in elements or "sand" in elements and Global.sand_coordinates.keys():
				var keys = Global.sand_coordinates.keys()
  				  # Check if the dictionary is not empty to avoid errors
				if keys.size() > 0:
					# Randomly select an index from the keys array
					var random_index = randi() % keys.size()
					# Retrieve the key (coordinate string) at the randomly selected index
					var coord_key = keys[random_index]
	   		 		# Split the key back into its original x, y components
					var coords = coord_key.split(",")
					var x = int(coords[0])
					var y = int(coords[1])
					var stone_vect = Vector2(x,y)
					#print("'stone' was found")
					var new_rock = rock.instantiate()
					new_rock.set_meta("Saveable",true)
					new_rock.set_meta("type","rock")
					new_rock.add_to_group("rocks")
					add_child(new_rock)
					new_rock.position =  stone_vect
					
		call_deferred("save_game")
		Global.new_map = false
	# else load existing map
	else:
		var current_scene = get_tree().current_scene
		var scene_path = Global.loaded_map
		var json_path = scene_path.replace(".tscn", ".json")
		print("json path: ",json_path)
		load_scene_from_file(json_path)
		


func generate_chunk(position,elements):
	var tile_pos = local_to_map(position)
	for x in range(width):
		for y in range(height):
			chosen_tile = null
			var moist = moisture.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var temp = temperature.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var alt = altitude.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			if moist > 5:
				moist = 5
			if temp > 5:
				temp = 5
			if alt > 5:
				alt = 5
			# choose map tile 
			if "grass" in elements:
				chosen_tile = choose_grass_tile(moist,temp, alt)
				if chosen_tile != null:
					var coord_key = str((tile_pos.x-width/2 + x)*10) + "," + str((tile_pos.y-height/2 + y)*10)
					print("coord_key from chunk: ", coord_key)
					# You can increment a counter or simply mark the position as having grass
					Global.grass_coordinates[coord_key] = true # Or increment if tracking counts
				
			if chosen_tile == null and "water" in elements:
				chosen_tile = choose_water_tile(moist,temp,alt)
				if chosen_tile != null:
					var coord_key = str((tile_pos.x-width/2 + x)*10) + "," + str((tile_pos.y-height/2 + y)*10)
					print("coord_key from chunk: ", coord_key)
					# You can increment a counter or simply mark the position as having grass
					Global.water_coordinates[coord_key] = true 
				
			if chosen_tile == null and "sand" in elements:
				chosen_tile = chose_sand_tile(moist,temp,alt)
				if chosen_tile != null:
					var coord_key = str((tile_pos.x-width/2 + x)*10) + "," + str((tile_pos.y-height/2 + y)*10)
					print("coord_key from chunk: ", coord_key)
					# You can increment a counter or simply mark the position as having grass
					Global.sand_coordinates[coord_key] = true 
			# Finally, set the chosen tile
			if chosen_tile:
				set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, chosen_tile)
			else:
				set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, steel_tile)
	'''
			if temp > max_temp:
				max_temp = temp
			if temp < min_temp:
				min_temp = temp
			if moist > max_moist:
				max_moist = moist
			if moist < min_moist:
				min_moist = moist
			if alt > max_alt:
				max_alt = alt
			if alt < min_alt:
				min_alt = alt
		
	print("max temp: ",max_temp)	
	print("min temp: ", min_temp)
	print("max moist: ",max_moist)	
	print("min moist: ", min_moist)
	print("max alt: ",max_alt)		
	print("min alt: ", min_alt)
	'''	
	
func choose_grass_tile(moist,temp,alt):
	if "grass" in elements and moist  >= -7 and moist <= -2.5 and temp >=-7 and temp <=-2.5:
		return grass_tile_1
	elif "grass" in elements and moist  > -2.5 and moist < 2 and temp >-7 and temp < -2.5:
		return grass_tile_2
	elif "grass" in elements and moist  > -7 and moist > -2.5 and temp < 2:
		return grass_tile_3
	elif "grass" in elements and moist  > -2.5 and moist < 2 and temp > 2.5 and moist < 2:
		return grass_tile_4
	elif "grass" in elements and moist  > -2.5 and moist < 2 and temp >= 2.5:
		return grass_tile_5
	else:
		return null

func chose_sand_tile(moist,temp,alt):
	if "sand" in elements and moist > -7.5 and temp > -2.5 and temp < 2:
		return sand_tile_1
	elif "sand" in elements and moist > -7.5 and temp >= 2.5:
		return sand_tile_2
	elif "sand" in elements and moist > -7 and moist < -2.5 and temp >= 2.5:
		return sand_tile_3
	else:
		return null
	
func choose_water_tile(moist,temp,alt):
	if "water" in elements and moist >= 2.5 and temp < -7.5:
		return water_tile_1
	elif "water" in elements and moist >= 2.5 and temp > -7 and temp < -2.5:
		return water_tile_2
	elif "water" in elements and moist >= 2.5 and temp > -2.5 and temp < 2:
		return water_tile_3
	elif "water" in elements and moist >= 2.5 and temp >= 2.5:
		return water_tile_4
	else:
		return null

func save_game():
	print("Save game called")
	var objects_data = []
	for object in get_children():
		# Using metadata
		print("type: ", object.get_meta("type"))
		if object.has_meta("Saveable"):
			print("saveable")
			var object_dict = {
			"type": object.get_meta("type"),
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
		
	var scene_path = "res://player_maps/" +  Global.map_name+ ".tscn"
	var current_scene = get_tree().current_scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(current_scene)
	if result == OK:
		var error = ResourceSaver.save(packed_scene, scene_path)  # Or "user://..."
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
	var in_file = FileAccess.open(scene_path, FileAccess.READ)
	if in_file:
		var scene_data = in_file.get_as_text()
		in_file.close()
		if Global.player_id != 99999 && Global.upload_map== true:
			Network._upload_map(Global.player_id, scene_data,json_data, Global.map_name)

	
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
				print("object_data: ", object_data)
				spawn_object(object_data)
		else:
			print("Failed to parse JSON")
	else:
		print("Failed to open file:", file_path)

func spawn_object(object_data):
	# Assuming object_data["type"] gives a string that corresponds to the resource path
	var resource_path = "res://scenes/" + object_data["type"] +"_scene" + ".tscn"
	var object_scene = load(resource_path) # Use load for runtime-determined paths
	var new_obj = object_scene.instantiate()
	add_child(new_obj)
	var position_string = object_data["position"].replace("(", "").replace(")", "")
	var position_elements = position_string.split(", ")
	var position_vector = Vector2(float(position_elements[0]), float(position_elements[1]))
	new_obj.position = position_vector
	







