extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude= FastNoiseLite.new()
var width = 500
var height = 500
var monster_count = 20
var resoruce_objects_count = 15

@onready var player = get_parent().get_child(2)
var offset_range = 1800
var enemey_offset_range = 800
var spawn_pos = Vector2(261.818, -57.2727)

func _ready():
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

	
	moisture.seed = randi()
	temperature.seed = randi()
	generate_chunk(player.position)
	
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
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

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
			
