extends CharacterBody2D

var can_collect = false

func _ready():
	hide()

func gem():
	pass
	
func _physics_process(delta):
	if Global.instance.tree_fallen:
		show()
		can_collect = true
	else:
		hide()
		can_collect = false

func _on_area_2d_body_entered(body):
	if body.has_method("player"):
		if can_collect == true:
			self.queue_free()
