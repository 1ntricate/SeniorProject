extends Control
# Please check the documentation about
# Displayserver class : https://docs.godotengine.org/en/stable/classes/class_displayserver.html

#--
# Check out Colorblind addon for godot : https://github.com/paulloz/godot-colorblindness
#--
var http_request : HTTPRequest = HTTPRequest.new()
const SERVER_URL = "http://174.134.25.64:5444/test.php"
#const SERVER_URL = "http://192.168.1.229/test.php"
const SERVER_HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Cache-Control: max-age=0"]
const SECRET_KEY = "1234567890"
var nonce = null
var request_queue : Array = []
var is_requesting : bool = false


@onready var Resolution_ob = get_node("%Resolution_Optionbutton")
@onready var OptionContainer = get_node("%OptionContainer")
@onready var MainContainer = get_node("%MainContainer")
@onready var LoginContainer = get_node("%LoginContainer")
@onready var login_button2 = get_node("%Login_button2")
@onready var username_input = get_node("%Username")
@onready var password_input = get_node("%Password")

var isUserLoggedIn = false
var loggedusername

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
	
	# Connect our buttons:
	#$AddScore.connect("pressed", Callable(self, "_submit_score()"))
	#$GetScores.connect("pressed", Callable(self, "_get_scores"))

	
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
	is_requesting = false
	if _result != HTTPRequest.RESULT_SUCCESS:
		printerr("Error w/ connection: " + String(_result))
		return
		
	var response_body = _body.get_string_from_utf8()
	# Grab our JSON and handle any errors reported by our PHP code:
	var test_json_conv = JSON.new()
	test_json_conv.parse(response_body)
	var response = test_json_conv.get_data()
	if response['error'] != "none":
		printerr("We returned error: " + response['error'])
		return
	
	# Check if we were requesting a nonce:
	if response['command'] == 'get_nonce':
		nonce = response['response']['nonce']
		print("Got nonce: " + response['response']['nonce'])
		return
		
	# If not requesting a nonce, we handle all other requests here:
	print("Response Body:\n" + response_body)

	# Check if the response contains a 'greeting' field and extract the username:
	if 'greeting' in response['response']:
		var greeting_message = response['response']['greeting']
		var username_start = greeting_message.find("Hello, ") + 7
		var username = greeting_message.substr(username_start)
		print("\nUsername: " + username)
		isUserLoggedIn = true
		if isUserLoggedIn == true:
			LoginContainer.visible = false
			MainContainer.visible = true
			#var welcomeLabel = $Welcome
			$MainContainer/Welcome.text = "Welcome, " + username
			#welcomeLabel.text = "Welcome, " + username
	else:
		print("Invalid Credentials")



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
	print("Requesting...\n\tCommand: " + request['command'] + "\n\tBody: " + body)


func _login(email,password):
	var command = "login"
	var data = {"email" : email, "password" : password}
	request_queue.push_back({"command" : command, "data" : data})
	
func _get_scores():
	var command = "get_users"
	var data = {"score_offset" : 0, "score_number" : 10}
	request_queue.push_back({"command" : command, "data" : data});


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")



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


func _on_apply_button_pressed():
	MainContainer.visible = true
	OptionContainer.visible = false
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
	


func _on_process_button_pressed():
	get_tree().change_scene_to_file("res://scenes/manage_images.tscn")




