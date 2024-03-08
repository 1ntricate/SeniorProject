extends Node

var instance = null
var drink = 0
var player_cur_dir = Vector2.LEFT
var player_current_atk = false
var player_in_range = false
var player_axe_atk = false
var selected_image_path = ""
var elements_identfied = ""
var tree_fallen = false
var is_laser = false
var shoot_laser = false
var auto_movement_enabled = true

var map_name = ""
var loaded_map = ""
var map_privacy = 0
var map_dsc = ""
var new_map = false
var map_list = []
var map_urls = []

var image_urls = []
var player_id = 99999
var isUserLoggedIn = false
var image_list = []
var active_requests = 0
var upload_map = false
var current_tree_hp_0 = false

var player_on_water = false
var player_on_sand = false
var skeleton_count = 0
var slime_count = 0
var goblin_count = 0
var spider_count = 0

var spawn_enemies = false
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
