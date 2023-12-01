extends Control

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_image_process_pressed():
	pass # Replace with function body.
