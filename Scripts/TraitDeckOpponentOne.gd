extends Node2D

const OPPONENT_CARD_SCENE_PATH = "res://Scenes/OpponentCard.tscn" # right click on Card.tscn and click copy path
const CARD_DRAW_SPEED = 0.2
const STARTING_HAND_SIZE = 1




var player_hand_reference
var opponent_one_hand_reference
var card_manager_reference
var trait_deck_node

const USER = "USER"
const OPPONENT_ONE = "OPPONENTONE"



	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Trait Deck Opp1 absolute node path ", self.get_path())
	player_hand_reference = $"../PlayerHand"
	card_manager_reference = $"../Card Manager"
	opponent_one_hand_reference = $"../OpponentOneHand"
	trait_deck_node = get_node("/root/Main/PlayerField/TraitDeck")

	$RichTextLabel.text = str(trait_deck_node.trait_deck.size())
	# for i in range (5):
	#	draw_card(OPPONENT_ONE)



	
func deck_clicked():
	
	# OLD CODE
	# var player_id = multiplayer.get_unique_id
	# When we draw a card, we also want to replicate that on our client's opponent field
	# await draw_here_and_for_clients_opponent(player_id)
	# Call the function for connected peers
	# rpc("draw_here_and_for_clients_opponent", player_id)
	var my_id = multiplayer.get_unique_id()
	print("deck clicked called TraitDeckOppponentOne.gd, id: ", my_id)
	rpc_id(1, "request_card_draw", my_id) # host id is 1, send to host
	# $RichTextLabel.text = str(trait_deck.trait_deck.size())
