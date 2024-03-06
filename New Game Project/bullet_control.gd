extends Sprite2D

@onready var player = get_parent().get_child(1)
var x_direction = 0
var y_direction = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#var scale = Vector2(,.1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position.x += 5 * x_direction
	position.y += 5 * y_direction
	
func bullet():
	pass
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

