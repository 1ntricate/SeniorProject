extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var elapsed_time = Global.time_survived
	var hours = elapsed_time / 3600
	var minutes = (elapsed_time % 3600) / 60
	var seconds = elapsed_time % 60
	# Format the time into a string of format "HH:MM:SS"
	$Sprite2D/Time.text = "%02d:%02d:%02d" % [hours, minutes, seconds]
	if Global.last_played_map_id != 0 and Global.isUserLoggedIn == true:
		Network._upload_time(Global.player_id, Global.last_played_map_id,elapsed_time)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_button_pressed():
	if Global.last_played_map != null:
		get_tree().change_scene_to_file(Global.last_played_map)
	else:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
