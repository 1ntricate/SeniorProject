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
	var error =[]
	print("Weight ration set to: ", weightValue) 
	# selected image path
	var image_path = Global.selected_image_path
	var script_base_path = "res://user/knn_v2/"
	var absolute_path = ProjectSettings.globalize_path("user://")
	var script_path = absolute_path + "/knn_v2/knn_v2.exe"
	var arguments = [weightValueStr, image_path]
	print("script_path: ", script_path)
	print(arguments)
	# Run the Python script and redirect output to files
	var result = OS.execute(script_path,arguments, output,true)
	var elements_counts = {}
	# Check if the script execution was successful
	if result == OK:
		# Read what elements were identfied in the knn scipt
		#var elements_path = ProjectSettings.globalize_path("identified_elements.txt")
		var elements_path = absolute_path + "/knn_v2/identified_elements.txt"
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
		print("output: ", output)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/manage_images.tscn")
	pass # Replace with function body.
