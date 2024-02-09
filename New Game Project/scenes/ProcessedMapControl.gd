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
	var enemy_scence = "res://scenes/enemy.tscn"
	var rock_scene = "res://scenes/rock_scene.tscn"
	var tree_scene = "res://scenes/tree_scene.tscn"
	var enemy = load(enemy_scence)
	var rock = load(rock_scene)
	var tree = load(tree_scene)
	
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()
	altitude.frequency = 0.005
	generate_chunk(player.position)
	var elements = Global.elements_identfied
	# spawn enemies
	
	# spawn elements as objects 
	for i in range (50):
		var random_offset_x = randf_range(-offset_range, offset_range)
		var random_offset_y = randf_range(-offset_range, offset_range)
		if "tree" in elements:
			print("'Tree' was found ")
			var new_tree = tree.instantiate()
			add_child(new_tree)
			new_tree.position =  +spawn_pos + Vector2(random_offset_x, random_offset_y)
		# Check for the word "Rock" in a case-insensitive manner
		if "stone" in elements:
			print("'stone' was found")
			var new_rock = rock.instantiate()
			add_child(new_rock)
			new_rock.position =  spawn_pos + Vector2(random_offset_x, random_offset_y)	
	
	call_deferred("save_game")
	
func generate_chunk(position):
	var tile_pos = local_to_map(position)
	print(player.position)

	for x in range(width):
		for y in range(height):
			var moist = moisture.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var temp = temperature.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var alt = altitude.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(round((moist+10)/5),(round((temp+10)/5))))
			
			#if alt < 2:
			#	set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(3, round((temp+10)/5)))
			#else:
			#	set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(round((moist+10)/5), round((temp+10)/5)))



func save_game():
	print("Save game called")
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
		var json = JSON.new()
		var save_data_result = json.parse(in_file.get_as_text())
		in_file.close()

		if save_data_result.error == OK:
			var save_data = save_data_result.result
			# Set player position
			player.position = save_data["player_position"]

			# Spawn objects
			for object_data in save_data["objects"]:
				spawn_object(object_data)

func spawn_object(object_data):
	# Assuming object_data["type"] gives a string that corresponds to the resource path
	var resource_path = "res://scenes/" + object_data["type"] + ".tscn"
	var object_scene = load(resource_path) # Use load for runtime-determined paths
	if object_scene:
		var object_instance = object_scene.instance()
		object_instance.position = object_data["position"]
		add_child(object_instance)
	else:
		print("Failed to load:", resource_path)



