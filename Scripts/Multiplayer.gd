extends Node2D

# The port that the server is listening for communications on
const PORT = 123

# The IP address of the server. If the client is trying to connect to a server on the same computer, use 'localhost'      
const SERVER_ADDRESS = "localhost"

#Creates a new multiplayer object called 'peer' using ENet networking library 
var peer = ENetMultiplayerPeer.new() 

# declaring a variable named player_field_scene with data type PackedScene
@export var player_field_scene: PackedScene

@export var opponent_one_field_scene: PackedScene



func _on_host_button_pressed() -> void:
	disable_buttons() 
	# Create server (Set our multiplayer object "peerOne" to a server that listens for communications on PORT
	peer.create_server(PORT)
	
	# 'multiplatyer' is a built-in property of all scenes in Godot (Accessible from anywhere)
	# 'multiplayer_peer' is a proplerty of multiplayer where we can assign the object responsible for networking
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	
	

func _on_join_opponent_one_button_pressed() -> void:
	disable_buttons()
	
	# Create client (Set our multiplayer object 'peerOne' to a client
	peer.create_client(SERVER_ADDRESS, PORT)
	
	multiplayer.multiplayer_peer = peer
	
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	
	
	# these two lines cause error
	var opponent_one_scene = opponent_one_field_scene.instantiate()
	add_child(opponent_one_scene)
	
	player_scene.client_set_up()
	
	await(10.0)
	
# Called when a client connects to the host (Will only call for the Host)
func _on_peer_connected(peer_id):
	var opponent_one_scene = opponent_one_field_scene.instantiate()
	
	add_child(opponent_one_scene)
	
	# I think works because PlayerField is a child of main (right click PlayerField.tscn, press "View Owners"
	get_node("PlayerField").host_set_up()
	
	# I added
	
	# print("Multiplayer.gd: Scene after opponent joins")
	# print_tree_pretty()
	
	

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinOpponentOneButton.disabled = true
	$JoinOpponentOneButton.visible = false
