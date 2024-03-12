extends Button

@export var action: String 
@onready var input_mapper = $".."
	
func _init():
	toggle_mode = true
	
func  _ready():
	set_process_unhandled_key_input(false)
	update_text()

func _toggled(button_pressed):
	set_process_unhandled_input(button_pressed)
	if button_pressed:
		text = "Press a key..."

func _unhandled_input(event):
	if event.is_action_pressed("key_input"):
		pass
	elif event.is_pressed():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		button_pressed = false
		release_focus()
		update_text()
		
func update_text():
	text = InputMap.action_get_events(action)[0].as_text()
