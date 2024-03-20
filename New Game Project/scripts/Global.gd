extends Node

var mobile_joined = false
var instance = null
var melee_equipped = ""
var ranged_equipped = ""

var drink = 0
var player_cur_dir = Vector2.LEFT
var player_current_atk = false
var player_in_range = false
var player_axe_atk = false

var player_base_dmg = 10
var weapon_dmg = ""

var tree_fallen = false
var is_changing_key_input = false
var shoot_laser = false

# player physics
var auto_movement_enabled = true
var player_on_water = false
var player_on_sand = false
var player_on_screen_button_left  = ""
var player_on_screen_button_right = ""

# enemy count/control
var skeleton_count = 0
var slime_count = 0
var goblin_count = 0
var spider_count = 0
var spawn_enemies = false
var current_tree_hp_0 = false

var spider_on_sand = false
var slime_on_water = false
var skeleton_on_snow = false

# player credentials
var player_id = 99999
var isUserLoggedIn = false
var player_user_name = null
# map misc
var map_name = ""
var selected_map = ""
var loaded_map = ""
var selected_map_path = ""
var map_privacy = 0
var map_dsc = ""
var new_map = false
var map_list = []
var thumb_list = []
var map_urls = []
var upload_map = false
var uploaded_map_id = null

# image misc
var selected_image_path = ""
var elements_identfied = ""
var elements_count = {}
var image_urls = []
var image_list = []
var active_requests = 0

func _ready():
	instance = self

func _process(delta):
	update_tree_hp()
	
func update_tree_hp():
	return current_tree_hp_0

func _on_button_pressed():
	pass
	
func setAutoMovementEnabled(enabled):
	auto_movement_enabled = enabled
	
func isAutoMovementEnabled():
	return auto_movement_enabled
