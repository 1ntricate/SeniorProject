extends Button

func _on_W_pressed():
	Global.player_on_screen_button_left = "w"
func _on_w_mouse_exited():
	Global.player_on_screen_button_left = ""
	
func _on_button_S_pressed():
	Global.player_on_screen_button_left = "s"
func _on_s_mouse_exited():
	Global.player_on_screen_button_left = ""
	
func _on_button_A_pressed():
	Global.player_on_screen_button_left = "a"
func _on_a_mouse_exited():
	Global.player_on_screen_button_left = ""

func _on_button_D_pressed():
	Global.player_on_screen_button_left = "d"
func _on_d_mouse_exited():
	Global.player_on_screen_button_left = ""
	
func _on_button_atk_pressed():
	Global.player_on_screen_button_right = "atk"
func _on_atk_mouse_exited():
	Global.player_on_screen_button_right = ""

func _on_button_I_pressed():
	Global.player_on_screen_button_right = "inven"
func _on_I_mouse_exited():
	Global.player_on_screen_button_right = ""
	



