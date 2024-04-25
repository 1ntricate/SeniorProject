extends Control

var max_stars = 5
var current_rating = 0

# Called when the node enters the scene tree for the first time.
'''
func _ready():
	for i in range(max_stars):
		var star = get_node("Star" + str(i + 1))
		#star.rect_min_size = star_size
	set_process_input(true)
	update_stars()
'''

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
