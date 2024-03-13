extends Camera2D
var filename_without_extension
var ssCount = 1
# Called when the node enters the scene tree for the first time.

func _ready():
	pass

func screenshot():
	await RenderingServer.frame_post_draw
	if Global.loaded_map == null:
		filename_without_extension = Global.map_name
	else:
		var parts = Global.loaded_map.split("/")
		var filename_with_extension = parts[-1]
		filename_without_extension = filename_with_extension.split(".")[0]
	var dir = DirAccess.open("res://player_screenshots/")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if !file_name.begins_with(".") and file_name.find(filename_without_extension) != -1:
			ssCount += 1
		file_name = dir.get_next()
	dir.list_dir_end()
	print("Screenshot")
	print("map name:" ,filename_without_extension)
	var viewport = get_viewport()
	var img = viewport.get_texture().get_image()
	img.save_png("res://player_screenshots/" +str(filename_without_extension) +str(ssCount) +".png")
	ssCount +=1                    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("--")
	if Input.is_action_just_pressed(("screenshot")):
		print("Screenshot key pressed")
		screenshot()

	
