extends Camera2D

var ssCount = 1
# Called when the node enters the scene tree for the first time.

func _ready():
	var dir = DirAccess.open("res://player_screenshots/")
	print("Camera2d Loaded")
	#dir.make_dir("screenshots")
	#dir = DirAccess.open("res://player_screenshots")
	for n in dir.get_files():
		ssCount+= 1

func screenshot():
	await RenderingServer.frame_post_draw
	print("Screenshot")
	var parts = Global.loaded_map.split("/")
	var filename_with_extension = parts[-1]
	var filename_without_extension = filename_with_extension.split(".")[0]
	
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

	
