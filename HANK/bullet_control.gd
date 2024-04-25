extends Sprite2D

@onready var player = get_parent().get_child(1)
var direction = 0
var notifier
var speed = 0
	
# Called when the node enters the scene tree for the first time.
func _ready():
	notifier = $VisibleOnScreenNotifier2D
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#look_at(position)
	position += direction * speed * delta
	if Global.player_on_water:
		reduce_bullet_travel()
	
func reduce_bullet_travel():
	var current_rect = notifier.position
	current_rect.x += current_rect.x
	current_rect.y += current_rect.y
	notifier.position = current_rect

func bullet():
	pass
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

