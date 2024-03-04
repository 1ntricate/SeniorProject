extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude= FastNoiseLite.new()
var width = 500
var height = 500
var monster_count = 10
var resoruce_objects_count = 25

@onready var player = get_parent().get_child(1)
var offset_range = 1800
var enemey_offset_range = 800
var spawn_pos = Vector2(0,0)

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


func _ready():
	var slime = preload("res://scenes/enemy.tscn")
	var skeleton = preload("res://scenes/skeleton.tscn")
	var goblin = preload("res://scenes/goblin.tscn")
	var spider = preload("res://scenes/spider.tscn")
	var rock = preload("res://scenes/rock_scene.tscn")
	var tree = preload("res://scenes/tree_scene.tscn")
	
	moisture.seed = randi()
	temperature.seed = randi()
	generate_chunk(player.position)
	
	# Spawn seperately to ensure unqique spawn positions
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_slime = slime.instantiate()
		add_child(new_slime)
		Global.slime_count += 1
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_slime.position = spawn_pos + Vector2(random_offset_x, random_offset_y)
		
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_skeleton = skeleton.instantiate()
		add_child(new_skeleton)
		Global.skeleton_count += 1
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_skeleton.position =  spawn_pos + Vector2(random_offset_x, random_offset_y)
	
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_spider = spider.instantiate()
		add_child(new_spider)
		Global.spider_count += 1
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_spider.position =  spawn_pos + Vector2(random_offset_x*2, random_offset_y*2)
		
	for i in range(monster_count):  # You can adjust the number of copies as needed
		var new_goblin = goblin.instantiate()
		add_child(new_goblin)
		Global.goblin_count += 1
		# set the position of each copy
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_goblin.position =  -spawn_pos + Vector2(random_offset_x, random_offset_y)

	for i in range(resoruce_objects_count):  # You can adjust the number of copies as needed
		var new_rock = rock.instantiate()
		add_child(new_rock)
		# set the position of each copy
		var random_offset_x = randf_range(-offset_range, offset_range)
		var random_offset_y = randf_range(-offset_range, offset_range)
		new_rock.position =  spawn_pos + Vector2(random_offset_x, random_offset_y)
		
	for i in range(resoruce_objects_count):  # You can adjust the number of copies as needed
		var new_tree = tree.instantiate()
		add_child(new_tree)
		# set the position of each copy
		var random_offset_x = randf_range(-offset_range, offset_range)
		var random_offset_y = randf_range(-offset_range, offset_range)
		new_tree.position =  +spawn_pos + Vector2(random_offset_x, random_offset_y)
		

func manage_enemy_spawning():
	check_enemy_count("enemy", Global.slime_count, 5)
	check_enemy_count("skeleton", Global.skeleton_count, 5)
	check_enemy_count("goblin", Global.goblin_count, 5)
	check_enemy_count("spider", Global.spider_count, 5)

func check_enemy_count(enemy_type, current_count, min_count):
	if current_count < min_count:
		spawn_enemies(enemy_type, min_count - current_count)

func enemy_wave():
	print("spawnning wave")
	spawn_enemies("enemy", 10) #slime
	spawn_enemies("skeleton", 10)
	spawn_enemies("goblin", 10)
	spawn_enemies("spider", 10)

func spawn_enemies(enemy_type, amount):
	var enemy_scene = load("res://scenes/" + enemy_type + ".tscn")
	
	for i in range(amount):
		var new_enemy = enemy_scene.instantiate()
		add_child(new_enemy)
		var random_offset_x = randf_range(-enemey_offset_range, enemey_offset_range)
		var random_offset_y = randf_range(-enemey_offset_range, enemey_offset_range)
		new_enemy.position = spawn_pos + Vector2(random_offset_x, random_offset_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_player_position2()
	#manage_enemy_spawning()
	if Global.spawn_enemies:
		enemy_wave()
		Global.spawn_enemies = false
		

	
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
		
# tilemap coordinates range from (0,0) to (3,3)
var tile_coordinates = {
	"snow_tile_1": Vector2(0, 0),
	"snow_tile_2": Vector2(0, 1),
	"snow_tile_3": Vector2(1, 0),
	"water_tile_1": Vector2(3, 0),
	"water_tile_2": Vector2(3, 1),
	"steel_tile_1": Vector2(2,0),
	"grass_tile_1": Vector2(1, 1),
	"grass_tile_2": Vector2(1, 2),
	"grass_tile_3": Vector2(2, 3),
	"sand_tile_1": Vector2(0, 2),
	"sand_tile_2": Vector2(0, 3)
}


func generate_chunk(position):
	var tile_pos = local_to_map(position)
	print(player.position)

	for x in range(width):
		for y in range(height):
			var moist = moisture.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var temp = temperature.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			print("og: "+ str(moist) +", " + str(temp))
			var alt = altitude.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var random = Vector2(round((moist+10)/5),(round((temp+10)/5)))
			set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(round((moist+10)/5),(round((temp+10)/5))))
			print("Rounded: "+ str(round(moist+10)/5) + ", " + str(round(temp+10)/5))
			
