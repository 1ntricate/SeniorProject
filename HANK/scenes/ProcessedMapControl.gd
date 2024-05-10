extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude= FastNoiseLite.new()
var width = 250
var height = 250
@onready var player = get_parent().get_child(1)
var offset_range = 1800
var elements = Global.elements_identfied
var monster_count = 25
var resoruce_objects_count = 20
var enemey_offset_range = 800

var chosen_tile = null
# tile coordinates
var water_tile_1 = Vector2i(3,0)
var water_tile_2 = Vector2i(3,1)
var water_tile_3 = Vector2i(3,2)
var water_tile_4 = Vector2i(3,3)
var water_tiles = [water_tile_1,water_tile_2,water_tile_3,water_tile_4]
var num_water_tiles = 0

var grass_tile_1 = Vector2i(1,1)
var grass_tile_2 = Vector2i(2,1)
var grass_tile_3 = Vector2i(1,2)
var grass_tile_4 = Vector2i(2,2)
var grass_tile_5 = Vector2i(2,3)
var grass_tiles = [grass_tile_1,grass_tile_2,grass_tile_3,grass_tile_4,grass_tile_5]

var sand_tile_1 = Vector2i(0,2)
var sand_tile_2 = Vector2i(0,3)
var sand_tile_3 = Vector2i(1,3)
var sand_tiles = [sand_tile_1,sand_tile_2,sand_tile_3]

# fall back tile if conditions aren't met
# or no elements identifed
var steel_tile = Vector2i(2,0)

var grass_positions = []
var sand_positions = []
var base_min_count = 10

func check_player_position2():
	var player_tile_pos = local_to_map(player.position)
	var tile_atlas_coords = get_cell_atlas_coords(0, player_tile_pos)
	if tile_atlas_coords in grass_tiles:
		#print("Player is on grass")
		pass
	
	if tile_atlas_coords in water_tiles:
		Global.player_on_water = true
		#print("Player is on water")
	else: 
		Global.player_on_water = false
		
	if tile_atlas_coords in sand_tiles:
		Global.player_on_sand = true
		#print("Player is on sand")
	else:
		Global.player_on_sand = false
		
func check_spider_position():
	var player_tile_pos = local_to_map(player.position)
	var tile_atlas_coords = get_cell_atlas_coords(0, player_tile_pos)
	if tile_atlas_coords in grass_tiles:
		#print("Player is on grass")
		pass
	
	if tile_atlas_coords in water_tiles:
		Global.player_on_water = true
		#print("Player is on water")
	else: 
		Global.player_on_water = false
		
	if tile_atlas_coords in sand_tiles:
		Global.player_on_sand = true
		#print("Player is on sand")
	else:
		Global.player_on_sand = false
		
func spawn_resoruces():
	var rock = preload("res://scenes/rock_scene.tscn")
	var tree = preload("res://scenes/tree_scene.tscn")
	# spawn objects 
	if "tree" in elements or "grass" in elements:
		if  grass_positions.size() > 0:
			for i in range (resoruce_objects_count):
				var random_index = randi() % grass_positions.size()
				var tree_pos = grass_positions[random_index]
				grass_positions.remove_at(random_index) # Remove to avoid spawning multiple trees on the same tile
				var new_tree = tree.instantiate()
				new_tree.set_meta("Saveable",true)
				new_tree.set_meta("type","tree")
				new_tree.add_to_group("tree")
				new_tree.position = map_to_local(tree_pos)
				add_child(new_tree)
	# ensure there is a food source			
	else:
		for i in range (16):
			var new_tree = tree.instantiate()
			add_child(new_tree)
		# set the position of each copy
			var random_offset_x = randf_range(-offset_range, offset_range)
			var random_offset_y = randf_range(-offset_range, offset_range)
			new_tree.position =  Vector2(random_offset_x, random_offset_y)
			new_tree.set_meta("Saveable",true)
			new_tree.set_meta("type","tree")
			new_tree.add_to_group("tree")
			#add_child(new_tree)	
			
	if "stone" in elements or "sand" in elements:
			if  sand_positions.size() > 0:
				for i in range (resoruce_objects_count):
					var random_index = randi() % sand_positions.size()
					var rock_pos = sand_positions[random_index]
					sand_positions.remove_at(random_index)
					var new_rock = rock.instantiate()
					new_rock.set_meta("Saveable",true)
					new_rock.set_meta("type","rock")
					new_rock.add_to_group("rocks")
					add_child(new_rock)
					new_rock.position = map_to_local(rock_pos)
	

func _ready():
	reset_enemies()
	Network.connect("map_uploaded", Callable(self,"_on_map_uploaded"))
	print("loaded map: ", Global.loaded_map)
	Global.last_played_map = Global.loaded_map
	#var rand_float = Time.get_unix_time_from_system()
	#rand_float.seed = randi()
	#RandomNumberGenerator.seed(rand_float)
	spawn_enemies()
	
	# if creating new map
	if Global.new_map:
		moisture.seed = randi()
		temperature.seed = randi()
		altitude.seed = randi()
		altitude.frequency = 0.005
		generate_chunk(player.position, elements)
		check_water(player.position)
		print("water tiles: ", num_water_tiles)
		spawn_resoruces()
		#spawn_resources()
		call_deferred("save_game")
		Global.new_map = false
		
	# else load existing map
	else:
		var current_scene = get_tree().current_scene
		var scene_path = Global.loaded_map
		var json_path = scene_path.replace(".tscn", ".json")
		print("json path: ",json_path)
		load_scene_from_file(json_path)

func reset_enemies():
	Global.skeleton_count = 0
	Global.slime_count = 0
	Global.goblin_count = 0
	Global.spider_count = 0
	
func check_water(position):
	var tile_pos = local_to_map(position)
	# if no water on map, add some
	if num_water_tiles <= 5:  # Adjust the condition based on your needs
		#print("adding water tiles")
		
		var random_center = get_random_position(width, height,5)
		# Convert random center to match the map coordinates used in chunk generation
		var center_x = tile_pos.x - width / 2 + random_center.x
		var center_y = tile_pos.y - height / 2 + random_center.y
		add_water_section(center_x, center_y, 5) 
		
func get_random_position(width, height, radius):
	var min_x = radius
	var max_x = width - radius - 1
	var min_y = radius
	var max_y = height - radius - 1
	var random_x = randi() % (max_x - min_x + 1) + min_x
	var random_y = randi() % (max_y - min_y + 1) + min_y
	return Vector2(random_x, random_y)


func add_water_section(center_x, center_y, radius):
	var water_tile = choose_tile_from_type('water')
	for x in range(center_x - radius, center_x + radius + 1):
		for y in range(center_y - radius, center_y + radius + 1):
			# Calculate offsets just like in your main loop
			
			#print("water tile:", water_tile)
			  # Set the water tile, checking boundaries if necessary
			#if x_offset >= 0 and x_offset < width and y_offset >= 0 and y_offset < height:
			set_cell(0, Vector2i(x, y), 0, water_tile)
			#print("Set water tile")
			num_water_tiles += 1
				


func _process(delta):
	#print(player.position)
	check_player_position2()
	var time_in_minutes = Global.time_survived / 60  # Convert seconds to minutes
	var increment_per_minute = 10
	var min_count = base_min_count + int(time_in_minutes) * increment_per_minute
	manage_enemy_spawning(min_count)

func spawn_enemies():
	# spawn enemies
	var slime = preload("res://scenes/enemy.tscn")
	var skeleton = preload("res://scenes/skeleton.tscn")
	var goblin = preload("res://scenes/goblin.tscn")
	var spider = preload("res://scenes/spider.tscn")
	print("elements: ", elements)
	# Spawn seperately to ensure unqique spawn positions
	for i in range(monster_count):
		var new_slime = slime.instantiate()
		add_child(new_slime)
		Global.slime_count += 1
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_slime.position = Vector2(random_offset_x, random_offset_y)
		
	for i in range(monster_count):  
		var new_skeleton = skeleton.instantiate()
		add_child(new_skeleton)
		Global.skeleton_count += 1
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_skeleton.position =  Vector2(random_offset_x, random_offset_y)
	
	for i in range(monster_count): 
		var new_spider = spider.instantiate()
		add_child(new_spider)
		Global.goblin_count += 1
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_spider.position =  Vector2(random_offset_x*2, random_offset_y*2)
		
	for i in range(monster_count): 
		var new_goblin = goblin.instantiate()
		add_child(new_goblin)
		Global.spider_count += 1
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_goblin.position =  Vector2(random_offset_x, random_offset_y)

func manage_enemy_spawning(min_count):
	check_enemy_count("enemy", Global.slime_count, min_count)
	check_enemy_count("skeleton", Global.skeleton_count, min_count)
	check_enemy_count("goblin", Global.goblin_count, min_count)
	check_enemy_count("spider", Global.spider_count, min_count)

func check_enemy_count(enemy_type, current_count, min_count):
	if current_count < min_count:
		spawn_wave_enemies(enemy_type, min_count - current_count)
		if enemy_type =="enemy":
			Global.slime_count += min_count- current_count
		elif enemy_type =="skeleton":
			Global.skeleton_count += min_count- current_count
		elif enemy_type =="goblin":
			Global.goblin_count += min_count- current_count
		elif enemy_type == "spider":
			Global.spider_count += min_count - current_count
		

func spawn_wave_enemies(enemy_type, amount):
	var enemy_scene = load("res://scenes/" + enemy_type + ".tscn")
	print("Spawning %d %s", amount, enemy_type)
	for i in range(amount):
		var new_enemy = enemy_scene.instantiate()
		add_child(new_enemy)
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_enemy.position =  Vector2(random_offset_x, random_offset_y)


func _on_map_uploaded():
	print("map uploaded")
	Global.upload_map = false
	var json_path = "user://maps/" +  Global.map_name+ ".json"
	var in_file = FileAccess.open(json_path, FileAccess.READ)
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
		print("MapID: ", Global.uploaded_map_id)
		#save_data["map_id"] = Global.last_played_map_id
		save_data["on_server"] = 1
		var json_data = json.stringify(save_data)
		var out_file = FileAccess.open(json_path,FileAccess.WRITE)
		if out_file:
			out_file.store_line(json_data)
			print("Added MapID to json")
	
func generate_chunk(position,elements):
	var tile_pos = local_to_map(position)
	for x in range(width):
		for y in range(height):
			var set_pos = Vector2((tile_pos.x-width/2 + x)*10, (tile_pos.y-height/2 + y)*10)
			var x_offset = tile_pos.x - width / 2 + x
			var y_offset = tile_pos.y - height / 2 + y
			chosen_tile = null
			var moist = moisture.get_noise_2d(x_offset, y_offset)*10
			var temp = temperature.get_noise_2d(x_offset, y_offset)*10
			var alt = altitude.get_noise_2d(x_offset, y_offset)*10
			moist = min(moist, 5)
			temp = min(temp, 5)
			alt = min(alt, 5)
			# choose map tile 
			if chosen_tile == null and ("grass" in elements or "tree" in elements):
				chosen_tile = choose_grass_tile(moist,temp, alt)
			if chosen_tile == null and "water" in elements:
				chosen_tile = choose_water_tile(moist,temp,alt)
				if chosen_tile !=null:
					num_water_tiles+=1
			if chosen_tile == null and "sand" in elements:
				chosen_tile = chose_sand_tile(moist,temp,alt)
			# Finally, set the chosen tile
			if chosen_tile:
				set_cell(0, Vector2i(x_offset,y_offset), 0, chosen_tile)
				if chosen_tile in grass_tiles:
					grass_positions.append(Vector2(x_offset,y_offset))
				if chosen_tile in sand_tiles:
					sand_positions.append(Vector2(x_offset,y_offset))
			# if no chosen_tile get the nearest tile type
			else:
				# get list of neighboring tiles - 4 adjacent
				var neighbors = get_neighboring_tiles(Vector2i(x_offset,y_offset))
				# if there are neighbors, chose the most common
				if neighbors !=null:
					if neighbors.size() > 0:
						#var chosen_tile_type = most_common_tile(neighbors)
						#chosen_tile = choose_tile_from_type(chosen_tile_type)
						chosen_tile = most_common_tile(neighbors)
						set_cell(0, Vector2i(x_offset,y_offset), 0, chosen_tile)
				# if no neighbors, use fall back tile
				else:
					#print("neighbors is null")
					set_cell(0, Vector2i(x_offset,y_offset), 0, steel_tile)

# builds the map following the ratio of identified elements
func generate_chunk_to_scale(position,elements):
	var tile_pos = local_to_map(position)
	
	var total_elements = 0
	for count in Global.elements_counts.values():
		total_elements += count
		
	var element_ratios = {}
	for element in Global.elements_counts.keys():
		Global.element_ratios[element] = Global.elements_counts[element] / float(total_elements)
	
	for x in range(width):
		for y in range(height):
			var set_pos = Vector2((tile_pos.x-width/2 + x)*10, (tile_pos.y-height/2 + y)*10)
			var x_offset = tile_pos.x - width / 2 + x
			var y_offset = tile_pos.y - height / 2 + y
			chosen_tile = null
			var moist = moisture.get_noise_2d(x_offset, y_offset)*10
			var temp = temperature.get_noise_2d(x_offset, y_offset)*10
			var alt = altitude.get_noise_2d(x_offset, y_offset)*10
			moist = min(moist, 5)
			temp = min(temp, 5)
			alt = min(alt, 5)
			# choose map tile 
			if chosen_tile == null and ("grass" in elements or "tree" in elements):
				chosen_tile = choose_grass_tile(moist,temp, alt)
			if chosen_tile == null and "water" in elements:
				chosen_tile = choose_water_tile(moist,temp,alt)
			if chosen_tile == null and "sand" in elements:
				chosen_tile = chose_sand_tile(moist,temp,alt)
			# Finally, set the chosen tile
			if chosen_tile:
				set_cell(0, Vector2i(x_offset,y_offset), 0, chosen_tile)
				if chosen_tile in grass_tiles:
					grass_positions.append(Vector2(x_offset,y_offset))
				if chosen_tile in sand_tiles:
					sand_positions.append(Vector2(x_offset,y_offset))
			# if no chosen_tile get the nearest tile type
			else:
				# get list of neighboring tiles - 4 adjacent
				var neighbors = get_neighboring_tiles(Vector2i(x_offset,y_offset))
				# if there are neighbors, chose the most common
				if neighbors.size() > 0:
					#var chosen_tile_type = most_common_tile(neighbors)
					#chosen_tile = choose_tile_from_type(chosen_tile_type)
					chosen_tile = most_common_tile(neighbors)
					set_cell(0, Vector2i(x_offset,y_offset), 0, chosen_tile)
				# if no neighbors, use fall back tile
				else:
					set_cell(0, Vector2i(x_offset,y_offset), 0, steel_tile)

func choose_tile_from_type(tile_type):
	if tile_type == 'grass':
		var index = randi() % grass_tiles.size()
		return grass_tiles[index]
	if tile_type == 'sand':
		var index = randi() % sand_tiles.size()
		return sand_tiles[index]
	if tile_type == 'water':
		var index = randi() % water_tiles.size()
		return water_tiles[index]
	if tile_type == 'snow':
		pass
	pass

func get_tile_type(tile_pos):
	var tile_atlas_coords = get_cell_atlas_coords(0, tile_pos)
	for grass_tile in grass_tiles:
		if tile_atlas_coords == grass_tile:
			return grass_tile 
	for water_tile in water_tiles:
		if tile_atlas_coords == water_tile:
			return water_tile  
	for sand_tile in sand_tiles:
		if tile_atlas_coords == sand_tile:
			return sand_tile  
	# else 
	return null  
		
func get_neighboring_tiles(tile_pos):
	var neighbors = []
	# Define offsets for directly adjacent tiles (4-connectivity)
	var offsets = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for offset in offsets:
		var neighbor_pos = tile_pos + offset
		var tile_type = get_tile_type(neighbor_pos) # Assume this function exists and returns the type of tile
		if tile_type != null:
			neighbors.append(tile_type)
			return neighbors

func most_common_tile(neighbors):
	var counts = {}
	# count each tile type (grass,water, sand, etc..)
	for tile in neighbors:
		if tile in counts:
			counts[tile] += 1
		else:
			counts[tile] = 1
	
	var most_common = null
	var highest_count = 0
	# get the most common tile 
	for tile in counts.keys():
		if counts[tile] > highest_count:
			highest_count = counts[tile]
			most_common = tile
	return most_common

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
	#print("Save game called")
	var objects_data = []
	for object in get_children():
		# Using metadata
		#print("type: ", object.get_meta("type"))
		if object.has_meta("Saveable"):
			#print("saveable")
			var object_dict = {
			"type": object.get_meta("type"),
			"position": object.position
			}
			objects_data.append(object_dict)
	var save_data = {
		"objects": objects_data,
		"map_id": 0,
		"on_server" : 0,
		"created_by": Global.player_user_name,
		"thumbnail": null,
		"description": Global.map_dsc,
		"privacy": Global.map_privacy
	}
	var json = JSON.new()
	var json_data = json.stringify(save_data)
	var j_file_path = "user://maps/" +  Global.map_name+ ".json"
	var out_file = FileAccess.open(j_file_path,FileAccess.WRITE)
	if out_file:
		out_file.store_line(json_data)
		
	var scene_path = "user://maps/" +  Global.map_name+ ".tscn"
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
			print("privacy from PMC: ", Global.map_privacy)
			Network._upload_map(Global.player_id, scene_data,json_data, Global.map_name,Global.map_privacy, Global.map_dsc,null,null)
		else:
			print("Upload conditions not met")
			
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
	

