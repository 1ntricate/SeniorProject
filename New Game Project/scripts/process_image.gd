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
	# Executable path
	var image_path = Global.selected_image_path
#######################################################################################################	
	# MAY NEED TO CHANGE PYTHON3 EXECUTABLE LOCATION
	var script_path = "/usr/bin/python3"  # Python executable

	#  CHANGE PATH TO SCRIPT HERE
	var arguments = ["/home/beto/Documents/GitHub/SeniorProject/image_processing/knn/knn_v2.py", weightValueStr, image_path]
	
#######################################################################################################	
	# Run the Python script and redirect output to files
	var result2 = OS.execute(script_path,arguments, output,true)
	#var exit_code = OS.execute("ls", [], output)
	print("Error executing Python script (Exit Code: ", result2, ")")



func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/manage_images.tscn")
	pass # Replace with function body.
