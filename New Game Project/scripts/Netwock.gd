extends Control

var http_request : HTTPRequest = HTTPRequest.new()
const SERVER_URL = "http://174.134.25.64:5444/test.php"
# const SERVER_URL = "http://192.168.1.229/test.php"
const SERVER_HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Cache-Control: max-age=0"]
const SECRET_KEY = "1234567890"
var nonce = null
var request_queue : Array = []
var is_requesting : bool = false

func _ready():
	randomize()
	
	# Connect our request handler:
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_http_request_completed"))
	
	# Connect our buttons:
	$AddScore.connect("pressed", Callable(self, "_submit_score"))
	$GetScores.connect("pressed", Callable(self, "_get_scores"))
	
	
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


func _submit_score():
	var score = 0
	var username = ""
	
	# Generate a random username
	var con = "bcdfghjklmnpqrstvwxyz"
	var vow = "aeiou"
	username = ""
	for _i in range(3 + randi() % 4):
		var string = con
		if _i % 2 == 0:
			string = vow
		username += string.substr(randi() % string.length(), 1)
		if _i == 0:
			username = username.capitalize()
	score = randi() % 1000
	
	var command = "add_user"
	var data = {"score" : score, "username" : username}
	request_queue.push_back({"command" : command, "data" : data})
	
	
func _get_scores():
	var command = "get_users"
	var data = {"score_offset" : 0, "score_number" : 10}
	request_queue.push_back({"command" : command, "data" : data});


func _on_db_connect_pressed():
	pass # Replace with function body.
