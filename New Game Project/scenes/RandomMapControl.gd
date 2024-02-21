extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude= FastNoiseLite.new()
var width = 500
var height = 500
var monster_count = 0
@onready var player = get_parent().get_child(2)
var offset_range = 800
var spawn_pos = Vector2(221.818, -87.2727)

func _ready():
	var enemy_scence = "res://scenes/enemy.tscn"
	var skeleton_scene = "res://scenes/skeleton.tscn"
	var goblin_scene = "res://scenes/goblin.tscn"
	var spider_scene = "res://scenes/spider.tscn"
	var rock_scene = "res://scenes/rock_scene.tscn"
	var tree_scene = "res://scenes/tree_scene.tscn"
	var enemy = load(enemy_scence)
	var skeleton = load(skeleton_scene)
	var spider = load(spider_scene)
	var goblin = load(goblin_scene)
	var rock = load(rock_scene)
	var tree = load(tree_scene)
	
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()
	altitude.frequency = 0.005
	generate_chunk(player.position)
	
	for i in range(50):  # You can adjust the number of copies as needed
		var new_enemy = enemy.instantiate()
		var new_skeleton = skeleton.instantiate()
		var new_spider = spider.instantiate()
		var new_goblin = goblin.instantiate()
		var new_rock = rock.instantiate()
		var new_tree = tree.instantiate()
		add_child(new_rock)
		add_child(new_tree)
		while monster_count < 100:
			add_child(new_enemy)
			add_child(new_skeleton)
			add_child(new_spider)
			add_child(new_goblin)
			monster_count += 4
			print("monster:" , monster_count)
		
		# set the position of each copy
		var random_offset_x = randf_range(-offset_range, offset_range)
		var random_offset_y = randf_range(-offset_range, offset_range)
		new_enemy.position = spawn_pos + Vector2(random_offset_x, random_offset_y)
		new_rock.position =  spawn_pos + Vector2(random_offset_x, random_offset_y)
		new_tree.position =  +spawn_pos + Vector2(random_offset_x, random_offset_y)
		new_goblin.position =  -spawn_pos + Vector2(random_offset_x, random_offset_y)
		new_spider.position =  spawn_pos + Vector2(random_offset_x*5, random_offset_y*5)
		new_skeleton.position =  spawn_pos + Vector2(random_offset_x/5, random_offset_y/5)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#print("position: ",player.position)
	
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

