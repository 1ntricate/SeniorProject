extends Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if Global.is_laser == false:
		hide()
	else:
		show()
		Global.shoot_laser = true

func laser():
	pass

