extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude= FastNoiseLite.new()
var width = 150
var height = 150
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

func check_player_position2():
	var player_tile_pos = local_to_map(player.position)
	var tile_atlas_coords = get_cell_atlas_coords(0, player_tile_pos)
	if tile_atlas_coords in grass_tiles:
		print("Player is on grass")
	
	if tile_atlas_coords in water_tiles:
		Global.player_on_water = true
		print("Player is on water")
	else: 
		Global.player_on_water = false
		
	if tile_atlas_coords in sand_tiles:
		Global.player_on_sand = true
		print("Player is on sand")
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
	# spawn enemies
	var slime = preload("res://scenes/enemy.tscn")
	var skeleton = preload("res://scenes/skeleton.tscn")
	var goblin = preload("res://scenes/goblin.tscn")
	var spider = preload("res://scenes/spider.tscn")

	# Spawn seperately to ensure unqique spawn positions
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_slime = slime.instantiate()
		add_child(new_slime)
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_slime.position = Vector2(random_offset_x, random_offset_y)
		
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_skeleton = skeleton.instantiate()
		add_child(new_skeleton)
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_skeleton.position =  Vector2(random_offset_x, random_offset_y)
	
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_spider = spider.instantiate()
		add_child(new_spider)
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_spider.position =  Vector2(random_offset_x*2, random_offset_y*2)
		
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_goblin = goblin.instantiate()
		add_child(new_goblin)
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_goblin.position =  Vector2(random_offset_x, random_offset_y)
		
	# if creating new map
	if Global.new_map:
		moisture.seed = randi()
		temperature.seed = randi()
		altitude.seed = randi()
		altitude.frequency = 0.005
		generate_chunk(player.position, elements)
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

func _process(delta):
	#print(player.position)
	check_player_position2()

func generate_chunk(position,elements):
	var tile_pos = local_to_map(position)
	for x in range(width):
		for y in range(height):
			var set_pos = Vector2((tile_pos.x-width/2 + x)*10, (tile_pos.y-height/2 + y)*10)
			#print("set_pos: ",set_pos)
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
			if "grass" in elements or "tree" in elements and chosen_tile == null:
				chosen_tile = choose_grass_tile(moist,temp, alt)
			if chosen_tile == null and "water" in elements:
				chosen_tile = choose_water_tile(moist,temp,alt)
			if chosen_tile == null and "sand" in elements:
				chosen_tile = chose_sand_tile(moist,temp,alt)
			# Finally, set the chosen tile
			if chosen_tile:
				set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, chosen_tile)
				if chosen_tile in grass_tiles:
					grass_positions.append(Vector2(tile_pos.x - width / 2 + x, tile_pos.y - height / 2 + y))
				if chosen_tile in sand_tiles:
					sand_positions.append(Vector2(tile_pos.x - width / 2 + x, tile_pos.y - height / 2 + y))
			else:
				set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, steel_tile)
				
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
		else:
			pass
			#print("Not saveable")
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
			print("privacy from PMC: ", Global.map_privacy)
			Network._upload_map(Global.player_id, scene_data,json_data, Global.map_name,Global.map_privacy, Global.map_dsc)

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
	

