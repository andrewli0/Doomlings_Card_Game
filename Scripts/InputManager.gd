extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released
signal double_clicked

const COLLISION_MASK_CARD = 1 # these should be same as in CardManager
const COLLISION_MASK_TRAIT_DECK = 4 # set mask to 3 in settings but 2 ^ (3-1) = 4
const COLLISION_MASK_AGE_DECK = 8 # set mask to 4 in settings but 2 ^ (4-1) = 8
const COLLISION_MASK_TRAIT_DISCARD_PILE = 256 # set mask to 9 in settings but 2 ^ (9-1) = 256
const COLLISION_MASK_AGE_DISCARD_PILE = 1024 # set mask to 11 in settings but 2 ^ (11-1) = 1024

var age_deck_reference
var age_discard_pile_reference
var battle_manager_reference
var card_manager_reference 
var player_hand_reference
var trait_deck_reference
var trait_discard_pile_reference

var deck_clicked = false # for debugging

const USER = "USER"
const OPPONENT_ONE = "OPPONENTONE"

func _ready() -> void:
	age_deck_reference = $"../AgeDeck"
	age_discard_pile_reference = $"../AgeDiscardPile"
	battle_manager_reference = $"../BattleManager"
	card_manager_reference = $"../Card Manager"
	player_hand_reference = $"../PlayerHand"
	trait_deck_reference = $"../TraitDeck"
	trait_discard_pile_reference = $"../TraitDiscardPile"
	

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click:
			print("InputManager: double clicked")
			emit_signal("double_clicked")
		elif event.pressed:
			print("left mouse button clicked")
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")
			pass


func raycast_at_cursor():

	#print("raycast check for portal to deck top: ", 
	#	card_manager_reference.raycast_check_for_portal_to_deck_top())
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD: 
			# Card clicked
			var card_found = result[0].collider.get_parent() # card node
			if card_found:
				# print("InputManager: card found")
				# he calls card_manager_reference.card_clicked because he needs
				# to do attacks when the card is clicked on the battlefield, and start drag when the card is in player's hand
				card_manager_reference.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_TRAIT_DECK and card_manager_reference.card_being_dragged == null:
			# OLD CODE: draw a card from trait deck
			# USER means is_player_turn, so card will flip
			trait_deck_reference.draw_card(battle_manager_reference.current_turn, true)
		elif result_collision_mask == COLLISION_MASK_AGE_DECK and card_manager_reference.card_being_dragged == null:
			# draw a card from age deck
			age_deck_reference.draw_card(battle_manager_reference.current_turn, true)
		elif result_collision_mask == COLLISION_MASK_TRAIT_DISCARD_PILE and card_manager_reference.card_being_dragged == null:
			# draw a card trait discard pile
			trait_discard_pile_reference.draw_card(battle_manager_reference.current_turn, true)
		elif result_collision_mask == COLLISION_MASK_AGE_DISCARD_PILE and card_manager_reference.card_being_dragged == null:
			# draw a card trait discard pile
			age_discard_pile_reference.draw_card(battle_manager_reference.current_turn, true)
	# print("raycast: card_being_dragged: ", card_manager_reference.card_being_dragged)
