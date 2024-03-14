extends Control
# Please check the documentation about
# Displayserver class : https://docs.godotengine.org/en/stable/classes/class_displayserver.html

#--
# Check out Colorblind addon for godot : https://github.com/paulloz/godot-colorblindness
#--
var http_request : HTTPRequest = HTTPRequest.new()
const SERVER_URL = "http://174.134.25.64:5444/godot.php"
#const SERVER_URL = "http://192.168.1.229/godot.php"
const SERVER_HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Cache-Control: max-age=0"]
const SECRET_KEY = "1234567890"
var nonce = null
var request_queue : Array = []
var is_requesting : bool = false

var map_options = ['Default Map', 'Randomized Map', 'Create new Map']
@onready var Resolution_ob = get_node("%Resolution_Optionbutton")
@onready var OptionContainer = get_node("%OptionContainer")
@onready var MainContainer = get_node("%MainContainer")
@onready var LoginContainer = get_node("%LoginContainer")
@onready var PlayContainer = get_node("%PlayContainer")
@onready var login_button2 = get_node("%Login_button2")
@onready var username_input = get_node("%Username")
@onready var password_input = get_node("%Password")
var map_name = ""
var image_name = ""
var download_queue = []
var is_request_active = false

signal images_received
signal map_list_received
signal map_received
signal map_uploaded
signal map_removed
signal map_updated
signal pulbic_map_list_ready

# Config file
# Move it into a singleton 
var SettingsFile = ConfigFile.new()
#--
var Vsync : int = 0
# I'm a Vector3 instead of 3 var float
# - x : General , y : Music , z : SFX
var Audio : Vector3 = Vector3(70.0,70.0,70.0)


func _get_resolution(index) -> Vector2i:
	var resolution_arr = Resolution_ob.get_item_text(index).split("x")
	return Vector2i(int(resolution_arr[0]),int(resolution_arr[1]))

func _check_resolution( resolution : Vector2i):
	for i in Resolution_ob.get_item_count() :
		if _get_resolution(i) == resolution :
			return i

func _first_time() -> void:
	DisplayServer.window_set_size(DisplayServer.screen_get_size())
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	DisplayServer.window_set_vsync_mode(Vsync)
	Resolution_ob.select(_check_resolution(DisplayServer.screen_get_size()))
	# -- Video
	SettingsFile.set_value("VIDEO","Resolution",_get_resolution(Resolution_ob.get_index()))
	SettingsFile.set_value("VIDEO","Vsync",Vsync)
	SettingsFile.set_value("VIDEO","Window Mode",_get_resolution(Resolution_ob.get_index()))
	SettingsFile.set_value("VIDEO","Graphics",_get_resolution(Resolution_ob.get_index()))
	SettingsFile.set_value("VIDEO","Color blind",_get_resolution(Resolution_ob.get_index()))
	# -- Audio
	SettingsFile.set_value("AUDIO","General",Audio.x)
	SettingsFile.set_value("AUDIO","Music",Audio.y)
	SettingsFile.set_value("AUDIO","SFX",Audio.z)
	
	SettingsFile.save("res://settings.cfg")


func _load_settings():
	if (SettingsFile.load("res://settings.cfg") != OK):
		_first_time()
	else:
		pass
func _save_settings() -> void:
	# -- Video
	SettingsFile.set_value("VIDEO","Resolution",_get_resolution(Resolution_ob.get_index()))
	SettingsFile.set_value("VIDEO","Vsync",Vsync)
	SettingsFile.set_value("VIDEO","Window Mode",_get_resolution(Resolution_ob.get_index()))
	SettingsFile.set_value("VIDEO","Graphics",_get_resolution(Resolution_ob.get_index()))
	SettingsFile.set_value("VIDEO","Color blind",_get_resolution(Resolution_ob.get_index()))
	# -- Audio
	SettingsFile.set_value("AUDIO","General",Audio.x)
	SettingsFile.set_value("AUDIO","Music",Audio.y)
	SettingsFile.set_value("AUDIO","SFX",Audio.z)
	
	SettingsFile.save("res://settings.cfg")


func _ready():
	_load_settings()
	#Resolution_ob.select(_check_resolution(DisplayServer.screen_get_size()))
	# Connect our request handler:
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_http_request_completed"))

	
func _process(_delta):
	
	# Check if we are good to send a request:
	if is_requesting:
		return
		
	if request_queue.is_empty():
		return
		
	is_requesting = true
	if nonce == null:
		request_nonce()
	else:
		_send_request(request_queue.pop_front())
		
func _http_request_completed(_result, _response_code, _headers, _body):
	var image_urls = []
	is_requesting = false
	if _result != HTTPRequest.RESULT_SUCCESS:
		printerr("Error w/ connection: " + String(_result))
		return
	var response_body = _body.get_string_from_utf8()
	print("Response Body:\n%s" % response_body)
	# Grab our JSON and handle any errors reported by our PHP code:
	var test_json_conv = JSON.new()
	test_json_conv.parse(response_body)
	var response = test_json_conv.get_data()
	# Check if we were requesting a nonce:
	if response['command'] == 'get_nonce':
		nonce = response['response']['nonce']
		print("Got nonce: " + response['response']['nonce'])
		return	
	if response['command'] == 'get_images':
		print("get images requested")
		if response.has("response") and response["response"] is Array:
			# Store the URLs in array
			image_urls = response["response"]
			Global.image_urls = image_urls
			emit_signal("images_received")
			
	if response['command'] == 'get_map_list':
		if response.has("response") and response["response"] is Array:
			# Store the URLs in array
			var map_list = response["response"]
			Global.map_list = map_list
			Network.connect("map_list_received", Callable(self, "_on_map_list_received"))
			# After successfully fetching the map list
			emit_signal("map_list_received")
	if response['command'] == 'upload_map':
		if response.has("response"):
			# Store the new map_id
			var reply = response["response"]
			var map_id = reply["map_id"]
			Global.uploaded_map_id  = map_id
			emit_signal("map_uploaded")
			
	if response['command'] == 'download_map':
		if response.has("response") and response["response"] is Array:
			# Store the URLs in array
			var map_urls = response["response"]
			Global.map_urls = map_urls
			Network.connect("map_received", Callable(self, "_on_map_received"))
			emit_signal("map_received")
			
	if response['command'] == 'remove_map':
		if response.has("response") and 'sucess' in response['response']:
			emit_signal("map_removed")
			
	if response['command'] == 'update_map':
		if response.has("response") and 'map_id' in response['response']:
			emit_signal("map_updated")
			
	# If not requesting a nonce, we handle all other requests here:
	# Check if the response contains a 'greeting' field and extract the username:
	if  'player_id' in response['response']:
		Global.player_id = response['response']['player_id']
		Global.player_user_name = response['response']['user_name']
		Global.isUserLoggedIn = true
		if Global.isUserLoggedIn == true:
			LoginContainer.visible = false
			MainContainer.visible = true
			#var welcomeLabel = $Welcome
			$MainContainer/Welcome.text = "Welcome, " + Global.player_user_name
			Network.connect("images_received", Callable(self, "_on_images_received"))
			Network._get_images(Global.player_id)

func request_nonce():
	var client = HTTPClient.new()
	var data = client.query_string_from_dict({"data" : JSON.stringify({})})
	var body = "command=get_nonce&" + data
	
	# Make request to the server:
	var err = http_request.request(SERVER_URL, SERVER_HEADERS, HTTPClient.METHOD_POST, body)


	# Check if there were problems:
	if err != OK:
		printerr("HTTPRequest error: " + err)
		return
		
	print("Requesting nonce...")
	
func _send_request(request: Dictionary):
	var client = HTTPClient.new()
	var data = client.query_string_from_dict({"data": JSON.stringify(request['data'])})
	var body = "command=" + request['command'] + "&" + data
	
	# Generate our 'response nonce' as a hexadecimal string
	var cnonce_bytes = Crypto.new().generate_random_bytes(32)
	var cnonce_hex = ""
	for byte in cnonce_bytes:
		cnonce_hex += "%02X" % byte
	
	# Generate our security hash:
	var client_hash = (nonce + cnonce_hex + body + SECRET_KEY).sha256_text()
	nonce = null
	
	# Create our custom header for the request:
	var headers = SERVER_HEADERS.duplicate()
	headers.push_back("cnonce: " + cnonce_hex)
	headers.push_back("hash: " + client_hash)
	
	# Make request to the server:
	var err = http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)

	# Check if there were problems:
	if err != OK:
		printerr("HTTPRequest error: " + err)
		return
	
	# Print out request for debugging:
	#print("Requesting...\n\tCommand: " + request['command'] + "\n\tBody: " + body)

func _on_images_received():
	_setup_requests(Global.image_urls)

func _on_map_list_received():
	_setup_p_maps_requests(Global.map_list)

func _on_map_received():
	_setup_map_requests(Global.map_urls)

func _setup_requests(urls):
	for link in urls:
		var image_info = {"url": link["url"], "filename": link["filename"]}
		download_queue.push_back(image_info)
	_process_next_request()		

func _setup_p_maps_requests(urls):
	for link in urls:
		var image_info = {"url": link["url"], "MapName": link["MapName"]}
		download_queue.push_back(image_info)
	_process_next_p_map_request()		
	
func _setup_map_requests(urls):
	for link in urls:
		var map_info = {"url": link["url"], "filename": link["filename"]}
		download_queue.push_back(map_info)
	_process_next_map_request()			
	
func _process_next_request():
	if download_queue.is_empty() or is_request_active:
		return # Exit if no items are in the queue or a request is active
	
	is_request_active = true
	var next_item = download_queue.pop_front()
	var image_url = next_item["url"]
	var file_name = next_item["filename"]
	image_name = file_name
	Global.image_list.append(file_name) 
	
	var http_request = HTTPRequest.new()
	http_request.request_completed.connect(self._http_request_completed2)
	add_child(http_request)
	var error = http_request.request(image_url)	

func _process_next_p_map_request():
	if download_queue.is_empty() or is_request_active:
		print("\n\n")
		print(Global.thumb_list)
		emit_signal("pulbic_map_list_ready")
		return # Exit if no items are in the queue or a request is active
	
	is_request_active = true
	var next_item = download_queue.pop_front()
	var image_url = next_item["url"]
	var map_name = next_item["MapName"]
	image_name = map_name
	Global.image_list.append(map_name) 
	
	var http_request = HTTPRequest.new()
	http_request.request_completed.connect(self._http_p_map_request_completed)
	add_child(http_request)
	var error = http_request.request(image_url)	


func _http_p_map_request_completed(result, response_code, headers, body):
	var file_name = image_name 
	is_request_active = false # Mark the current request as completed
	var save_path = "res://player_images/"
	var full_save_path = save_path + file_name
	if result == HTTPRequest.RESULT_SUCCESS:
		var image = Image.new()
		var error = image.load_png_from_buffer(body)
		if error == OK:
			var texture = ImageTexture.create_from_image(image)
			var image_info = {"filename": file_name, "texture": texture}
			# Append the dictionary to the thumb_list array
			Global.thumb_list.append(image_info)
		else:
			print("Error")
	_process_next_p_map_request()# Process the next item in the queue

func _http_request_completed2(result, response_code, headers, body):
	var file_name = image_name 
	is_request_active = false # Mark the current request as completed
	var save_path = "res://player_images/"
	var full_save_path = save_path + file_name
	if result == HTTPRequest.RESULT_SUCCESS:
		if !FileAccess.file_exists(full_save_path):
			var out_file = FileAccess.open(full_save_path, FileAccess.WRITE)
			if out_file:
				out_file.store_buffer(body)
				out_file.close()
				print(file_name + " added to directory.")
		else:
			print("Image already downloaded")
	_process_next_request() # Process the next item in the queue


func _process_next_map_request():
	if download_queue.is_empty() or is_request_active:
		return # Exit if no items are in the queue or a request is active
	is_request_active = true
	var next_item = download_queue.pop_front()
	var map_url = next_item["url"]
	var file_name = next_item["filename"]
	map_name = file_name
	#Global.map_list.append(file_name) 
	
	var http_request = HTTPRequest.new()
	http_request.request_completed.connect(self._http_map_request_completed)
	add_child(http_request)
	var error = http_request.request(map_url)	

			
func _http_map_request_completed(result, response_code, headers, body):
	var file_name = map_name
	var out_file
	is_request_active = false 
	var save_path1 = "res://player_maps/"
	var save_path2 = "res://player_screenshots/"
	if result == HTTPRequest.RESULT_SUCCESS:
		var full_save_path1 = save_path1 + file_name	
		var full_save_path2 = save_path2 + file_name
		print("checking map name: ", file_name)
		if file_name.ends_with(".png"):
			print("PNG detected")
			out_file = FileAccess.open(full_save_path2, FileAccess.WRITE)
		else:
			out_file = FileAccess.open(full_save_path1, FileAccess.WRITE)
		#var filer_name = request_to_filename[http_request]
		if out_file:
			out_file.store_buffer(body)
			out_file.close()
			print("Map Downloaded")
	else:
		print("Resuls not sucessful")
	_process_next_map_request()	

func _generate_random_string(length: int) -> String:
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	var random_string = ""
	for i in length: # Note: In Godot 4.2, use '..' for inclusive range
		var index = randi() % characters.length()
		random_string += characters[index]
	return random_string	

func _login(email,password):
	var command = "login"
	var data = {"email" : email, "password" : password}
	request_queue.push_back({"command" : command, "data" : data})

func _get_images(player_id):
	var command = "get_images"
	var data = {"PlayerID" : player_id}
	request_queue.push_back({"command" : command, "data" : data})
	
func _upload_image(player_id,file_name,image):
	var command = "upload_image"
	var data = {"PlayerID" : player_id, "file_name": file_name, "image": image}
	request_queue.push_back({"command" : command, "data" : data})
	
func _process_image(weight,image):
	print("process image called")
	var command = "knn"
	var data = {"weight" : weight, "image_path":image}
	request_queue.push_back({"command" : command, "data" : data})
	
func _get_maps(PlayerID):
	print("get maps called")
	var command = "get_maps"
	var data = {"PlayerID" : PlayerID}
	request_queue.push_back({"command" : command, "data" : data})

func _upload_map(PlayerID, scene,position_data, file_name,privacy,description, thumbnail,thumb_file_name):
	print("upload map called")
	print("dsc from _upload_map(): ", description)
	var command = "upload_map"
	var data = {"PlayerID" : PlayerID, "scene": scene, "pos_data": position_data, "file_name": file_name, "privacy": privacy, "description": description, "thumbnail": thumbnail,"thumb_name": thumb_file_name}
	request_queue.push_back({"command" : command, "data" : data})

func _remove_map(PlayerID, MapID):
	var command = "remove_map"
	var data = {"PlayerID" : PlayerID, "map_id": MapID}
	request_queue.push_back({"command" : command, "data" : data})

func _upvote_map(MapID):
	var command = "upvote_map"
	var data = {"map_id": MapID}
	request_queue.push_back({"command" : command, "data" : data})

func _downvote_map(MapID):
	var command = "downvote_map"
	var data = {"map_id": MapID}
	request_queue.push_back({"command" : command, "data" : data})



func _update_map(PlayerID, MapID,scene,position_data, file_name,privacy,description, thumbnail,thumb_file_name):
	var command = "update_map"
	if position_data == null:
		print("Error json file empty")
	var data = {"PlayerID" : PlayerID,"Map_id": MapID, "scene": scene, "pos_data": position_data, "file_name": file_name, "privacy": privacy, "description": description, "thumbnail": thumbnail, "thumb_name":thumb_file_name}
	request_queue.push_back({"command" : command, "data" : data})
	
func get_map_list():
	var command = "get_map_list"
	var data = {"Dummy" : 1029}
	request_queue.push_back({"command" : command, "data" : data})

func download_map(map_id,flag):
	var command = "download_map"
	var data = {"MapID" : map_id, "Flag": flag}
	request_queue.push_back({"command" : command, "data" : data})
	

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MapMenu.tscn")
	PlayContainer.visible = true
	MainContainer.visible = false


func _on_option_button_pressed():
	OptionContainer.visible = true
	MainContainer.visible = false



func _on_exit_button_pressed():
	get_tree().quit()


# -- VIDEO TAB --

func _on_resolution_optionbutton_item_selected(index):
	DisplayServer.window_set_size(_get_resolution(index))



@warning_ignore("unused_parameter")
func _on_window_mode_optionbutton_item_selected(index):
	pass # Replace with function body.




@warning_ignore("unused_parameter")
func _on_preset_h_slider_value_changed(value):
	# start here https://docs.godotengine.org/en/stable/tutorials/3d/mesh_lod.html
	pass # Replace with function body.


# -- AUDIO TAB --

func _on_general_h_scroll_bar_value_changed(value):
	Audio.x = value


func _on_music_h_scroll_bar_value_changed(value):
	Audio.y = value


func _on_sfx_h_scroll_bar_value_changed(value):
	Audio.z = value


# -- Save and Exit buttons

func _on_return_button_pressed():
	MainContainer.visible = true
	OptionContainer.visible = false
	LoginContainer.visible = false
	PlayContainer.visible = false


func _on_apply_button_pressed():
	MainContainer.visible = true
	OptionContainer.visible = false
	PlayContainer.visible = false
	_save_settings()



func _on_vsync_option_button_item_selected(index):
	# check the documentation about Vsync : https://docs.godotengine.org/en/stable/classes/class_displayserver.html#enum-displayserver-vsyncmode
	Vsync = index


func _on_login_button_pressed():
	LoginContainer.visible = true
	MainContainer.visible = false
	

func _on_login_button_2_pressed():
	if username_input.text == "" or password_input.text == "":
		print("Please Enter a valid Username and Password Combo")
	else:
		login_button2.disabled = true
		var username = username_input.get_text()
		var password = password_input.get_text()
		print("Attempting to login...")
		_login(username,password)
		
	

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_map_list_pressed():
	print("Pressed")


func _on_manage_img_button_pressed():
	#get_tree().change_scene_to_file("res://gallery.tscn")
	get_tree().change_scene_to_file("res://scenes/image_list.tscn")


func _on_browse_maps_button_pressed():
	get_tree().change_scene_to_file("res://scenes/public_maps.tscn")
	
