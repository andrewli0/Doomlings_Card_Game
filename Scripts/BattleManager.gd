extends Node

const BASE_CARD_SCALE = 0.55
const CARD_MOVE_SPEED = 0.2

var battle_timer
var trait_deck_reference
var player_hand_node
var opponent_one_hand_node
const USER = "USER"
const OPPONENT_ONE = "OPPONENTONE"
var empty_opponent_one_card_slots = []
var opponent_one_cards_on_field = []
var current_turn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true # so the timer doenst loop over and over
	battle_timer.wait_time = 1.0 # 1 second
	trait_deck_reference =  $"../TraitDeck"
	for i in range(1, 31): # from, limit
		var path = "../OpponentOneCardSlots/OpponentOneCardSlot"+str(i)
		empty_opponent_one_card_slots.append(get_node(path))
		
	player_hand_node = $"../PlayerHand"
	opponent_one_hand_node = $"../OpponentHand"
	current_turn = USER

# auto generated because EndTurnButton is connected to BattleManager script
# called if we press the end turn button
func _on_end_turn_button_pressed() -> void:
	# TODO
	# change the text on CurentTurn
	if current_turn == USER:
		current_turn = OPPONENT_ONE
		$"../CurrentTurn".text = "CURRENT TURN: OPPONENT_ONE"
	elif current_turn == OPPONENT_ONE:
		current_turn = USER
		$"../CurrentTurn".text = "CURRENT TURN: USER"
	else: 
		print("error BattleManger: _on_end_turn_button_pressed, invalid current_turn")
	player_hand_node.update_hand_positions(CARD_MOVE_SPEED)
	opponent_one_hand_node.update_hand_positions(CARD_MOVE_SPEED)
#func opponent_turn():
	#$"../EndTurnButton".disabled = true
	#$"../EndTurnButton".visible = false
	#
	## Wait 1 second
	#battle_timer.start()
	#await battle_timer.timeout
	#
	#
	## check if free card slots and if no, return
	#if empty_opponent_one_card_slots.size() != 0:
		## try_play_card and wait 1 second if played. 
		## Since we have a timer in try_play_card, await keywords makes us wait for try_play_card( to finish
		#await try_play_card()
		#print("BattleManager.gd: Opponent HAS empty card slots to play a card into")
			#
	## If can draw a card, draw, then wait 1 second (equivilant of stabalizing)
	#if trait_deck_reference.trait_deck.size() != 0:
		#$"../TraitDeck".draw_card(OPPONENT_ONE) # parameter so the computer knows which hand to draw into
		## Wait 1 second
		#battle_timer.start()
		#await battle_timer.timeout 
	#else:
		#print("BattleManager.gd: Cannot draw card, trait deck empty")
#
	#end_opponent_turn()

#func try_play_card():
	#
	## opponent_one_hand is a reference to OpponentOne's array representing their hand
	#var opponent_one_hand_array = opponent_one_hand_node.opponent_one_hand
	#
	## check if there is a card in hand
	#if opponent_one_hand_array.size() == 0:
		#print("BattleManager.gd: Opponent's hand is empty, ending opponent turn")
		#end_opponent_turn()
		#return
	#
	## get a random free slot to play the card in
	#var random_empty_opponent_one_card_slot = empty_opponent_one_card_slots.pick_random()
	#empty_opponent_one_card_slots.erase(random_empty_opponent_one_card_slot)
	#print("BattleManager.gd: empty_opponent_one_card_slots.size():", empty_opponent_one_card_slots.size())
	#
	## just play the first card in hand. Video said play card with highest attack. 
	#var card_to_play = opponent_one_hand_array[0]
	#
	## animate card into position. Taken from PlayerHand script animate_card_to_position(...)
	#var tween = get_tree().create_tween() 
	#tween.tween_property(card_to_play, "position", random_empty_opponent_one_card_slot.position, CARD_MOVE_SPEED) 
	#var tween2 = get_tree().create_tween() 
	#tween2.tween_property(card_to_play, "scale", Vector2(BASE_CARD_SCALE, BASE_CARD_SCALE), CARD_MOVE_SPEED) 
	#card_to_play.get_node("AnimationPlayer").play("card_flip_to_front") 
#
	## Remove this card from opponents hand
	#opponent_one_hand_node.remove_card_from_hand(card_to_play)
	#opponent_one_cards_on_field.append(card_to_play)
	## print("BattleManager.gd: opponent cards on battle field: ", opponent_one_cards_on_field)
	#
	## Wait 1 second
	#await wait(1.0)

func wait(wait_time):
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout
	

#func end_opponent_turn():
	## end turn
	#$"../EndTurnButton".disabled = false
	#$"../EndTurnButton".visible = true
#
#func enable_end_turn_button (is_enabled) :
	#if is_enabled:
		#$"../EndTurnButton".visible = true
		#$"../EndTurnButton".disabled = true
	#else :
		#$"../EndTurnButton".visible = false
		#$"../EndTurnButton".disabled = true
	

func _on_flip_cards_user_hand_to_back_pressed() -> void:
	# flip the cards in users hand to back
	for i in range(player_hand_node.player_hand.size()):
		# print("flipping user cards to back")
		player_hand_node.player_hand[i].get_node("AnimationPlayer").play("card_flip_to_back") 


func _on_flip_cards_opponent_hand_to_back_pressed() -> void:
	# flip the cards in opponent's hand to back
	for i in range(opponent_one_hand_node.opponent_one_hand.size()):
		# print("flipping opponent cards to back")
		opponent_one_hand_node.opponent_one_hand[i].get_node("AnimationPlayer").play("card_flip_to_back") 

func _on_flip_cards_user_hand_to_front_pressed() -> void:
	# flip the cards in users hand to front
	for i in range(player_hand_node.player_hand.size()):
		# print("flipping user cards to front")
		player_hand_node.player_hand[i].get_node("AnimationPlayer").play("card_flip_to_front") 


func _on_flip_cards_opponent_hand_to_front_pressed() -> void:
	# flip the cards in oppponent hand to front
	for i in range(opponent_one_hand_node.opponent_one_hand.size()):
		# print("flipping opponent cards to front")
		opponent_one_hand_node.opponent_one_hand[i].get_node("AnimationPlayer").play("card_flip_to_front") 
