extends Node2D

var slider
# Called when the node enters the scene tree for the first time.
func _ready():
	slider = $HScrollBar
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_process_button_pressed():
	var weightValue = slider.value
	print("Sider value:", weightValue)
	 # Convert sliderValue to string and include in arguments
	var weightValueStr = str(weightValue)
	var output = []
	print("Weight ration set to: ", weightValue) 
	# selected image path
	var image_path = Global.selected_image_path
	#var image_path = "6_landscape.jpg"
	#Network._process_image(weightValueStr,image_path)
	
	# MAY NEED TO CHANGE PYTHON3 EXECUTABLE LOCATION
	var script_path = "/usr/bin/python3" # Python executable
	var absolute_path = ProjectSettings.globalize_path("res://")
	var knn_path = absolute_path.replace("New Game Project/", "image_processing/knn/knn_v2.py")
	var arguments = [knn_path, weightValueStr, image_path]
	# Run the Python script and redirect output to files
	var result = OS.execute(script_path,arguments, output,true)
	var elements_counts = {}
	# Check if the script execution was successful
	if result == OK:
		# Read what elements were identfied in the knn scipt
		var elements_path = absolute_path.replace("New Game Project/", "image_processing/knn/identified_elements.txt")
		var file = FileAccess.open(elements_path, FileAccess.READ)
		if file != null:
			var file_contents = file.get_as_text()
			Global.elements_identfied = file_contents
			while not file.eof_reached():
				var line = file.get_line().strip_edges()
				if line != "":
					var parts = line.split(":")
					if parts.size() == 2:
						var element = parts[0].strip_edges()
						var count = int(parts[1].strip_edges())
						elements_counts[element] = count
			file.close()
			Global.elements_count = elements_counts
			print("Elements Identfied:")
			print(file_contents)
			get_tree().change_scene_to_file("res://scenes/Map_Creator.tscn")
			
			
		else:
			print("Failed to open the output file:", elements_path)
	else:
		# Handle the case where the script execution failed
		print("Script execution failed with error code:", result)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/manage_images.tscn")
	pass # Replace with function body.
