extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#var scale = Vector2(,.1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position.x += 5
	
func bullet():
	pass
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

