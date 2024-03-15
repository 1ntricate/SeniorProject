extends Button

func _on_W_pressed():
	Global.player_on_screen_button_left = "w"
	
func _on_button_S_pressed():
	Global.player_on_screen_button_left = "s"

func _on_button_A_pressed():
	Global.player_on_screen_button_left = "a"

func _on_button_D_pressed():
	Global.player_on_screen_button_left = "d"

func _on_button_atk_pressed():
	Global.player_on_screen_button_right = "atk"

func _on_button_I_pressed():
	Global.player_on_screen_button_right = "inven"

