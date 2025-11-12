extends Node2D
const COLLISION_MASK_CARD = 1 # set mask to k = 1 in settings but 2 ^ (k-1) = 1
const COLLISION_MASK_CARD_SLOT = 2 # set mask to k = 2 in settings but 2 ^ (k-1) = 2
const COLLISION_MASK_TRAIT_DECK = 4 # set mask to 3 in settings but 2 ^ (3-1) = 4
const COLLISION_MASK_AGE_DECK = 8 # set mask to 4 in settings but 2 ^ (4-1) = 8

const COLLISION_MASK_AGE_DECK_TOP = 64 # set mask to 7 in settings but 2 ^ (7-1) = 64
const COLLISION_MASK_TRAIT_DECK_TOP = 128 # set mask to 8 in settings but 2 ^ (8-1) = 128
const COLLISION_MASK_TRAIT_DISCARD_PILE_TOP = 512 # set mask to 10 in settings but 2 ^ (10 - 1) = 512
const COLLISION_MASK_AGE_DISCARD_PILE_TOP = 2048 # set mask to 12 in settings but 2 ^ (12 - 1) = 2048

const BASE_CARD_SCALE = 0.55
const SMALL_CARD_SCALE = 0.1
const HOVERED_CARD_SCALE = 0.9 # 0.65 # make 1 so can read the card
const DEFUALT_CARD_MOVE_SPEED = 0.1
var screen_size
var card_being_dragged
var is_hovering_on_card
var player_hand_reference
var opponent_hand_reference
var trait_deck_reference
var age_deck_reference
var trait_discard_pile_reference
var age_discard_pile_reference
var previous_click_time
var current_click_time
var battle_manager_reference

# Called when the node enters the scene tree for the first tiem
func _ready() -> void:
	# print("Card Manager: ready")
	current_click_time = -1
	previous_click_time = -1
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	opponent_hand_reference = $"../OpponentHand"
	trait_deck_reference = $"../TraitDeck"
	age_deck_reference = $"../AgeDeck"
	trait_discard_pile_reference = $"../TraitDiscardPile"
	age_discard_pile_reference = $"../AgeDiscardPile"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released) 
	# connect the signal left_mouse_button_released from the InputManager Script to the function on_left_click_released() 
	battle_manager_reference = $"../BattleManager";

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), 
					clamp(mouse_pos.y, 0, screen_size.y))


func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(BASE_CARD_SCALE, BASE_CARD_SCALE)
	
	# if we are dragging out of a card slot, make the card slot vacant
	var card_slot_found = raycast_check_for_card_slot()
	if (card_slot_found and card_slot_found.card_in_slot):
		card_slot_found.card_in_slot = false
		card_being_dragged.card_slot_card_is_in = null


func finish_drag():
	
	# i added
	if card_being_dragged == null : return
	
	if card_being_dragged: card_being_dragged.scale = Vector2(HOVERED_CARD_SCALE, HOVERED_CARD_SCALE)
	
	# print(card_slot_found)
	
	# I ADDED: To put a card back at the top of the deck
	var card_slot_found = raycast_check_for_card_slot()
	var portal_to_trait_deck_top_found = raycast_check_for_portal_to_trait_deck_top()
	var portal_to_age_deck_top_found = raycast_check_for_portal_to_age_deck_top()
	var portal_to_trait_discard_top_found = raycast_check_for_portal_to_trait_discard_top()
	var portal_to_age_discard_top_found = raycast_check_for_portal_to_age_discard_top()
	
	
	if card_slot_found:
		pass
		# print(card_slot_found.card_in_slot)
	
	
	# print("deck_found finish_drag", portal_to_deck_top_found)
	if card_being_dragged != null and portal_to_trait_deck_top_found:
		# Drag ended at portal to top
		trait_deck_reference.add_card_to_top(card_being_dragged)
		if player_hand_reference.player_hand.has(card_being_dragged):
			player_hand_reference.remove_card_from_hand(card_being_dragged) 
		elif opponent_hand_reference.opponent_one_hand.has(card_being_dragged):
			opponent_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true 
		# what disableing collasion shape does:
		# Before. Say I am dragging a card I drag it over the Portal to Deck Top, release it , 
		# then click portal again
		# A second card then goes through portal. Now this doesnt happen
		card_being_dragged.visible = false
		player_hand_reference.update_hand_positions(DEFUALT_CARD_MOVE_SPEED)	
		
		# i know this is sloppy
		opponent_hand_reference.update_hand_positions(DEFUALT_CARD_MOVE_SPEED)	
		
		# print("dragged ", card_being_dragged, " to portal to trait deck top")	
		card_being_dragged = null # need to do this immedately. 
		# otherwise if drag a card to portal to deck top, release, then click again, another card goes through, because when release, card_being_dragged is checked
	elif card_being_dragged != null and portal_to_age_deck_top_found: # Age deck top
		if player_hand_reference.player_hand.has(card_being_dragged):
			player_hand_reference.remove_card_from_hand(card_being_dragged) 
		elif opponent_hand_reference.opponent_one_hand.has(card_being_dragged):
			opponent_hand_reference.remove_card_from_hand(card_being_dragged)
		
		age_deck_reference.add_card_to_top(card_being_dragged)
		player_hand_reference.remove_card_from_hand(card_being_dragged) 
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true 
		card_being_dragged.visible = false
		player_hand_reference.update_hand_positions(DEFUALT_CARD_MOVE_SPEED)
		opponent_hand_reference.update_hand_positions(DEFUALT_CARD_MOVE_SPEED)	
		# print("dragged ", card_being_dragged, " to portal to age deck top")
		card_being_dragged = null # need to do this immedately. 
	elif card_being_dragged != null and portal_to_trait_discard_top_found: # Trait discard top
		if player_hand_reference.player_hand.has(card_being_dragged):
			player_hand_reference.remove_card_from_hand(card_being_dragged) 
		elif opponent_hand_reference.opponent_one_hand.has(card_being_dragged):
			opponent_hand_reference.remove_card_from_hand(card_being_dragged)
		
		trait_discard_pile_reference.add_card_to_top(card_being_dragged)
		player_hand_reference.remove_card_from_hand(card_being_dragged) 
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true 
		card_being_dragged.visible = false
		player_hand_reference.update_hand_positions(DEFUALT_CARD_MOVE_SPEED)
		opponent_hand_reference.update_hand_positions(DEFUALT_CARD_MOVE_SPEED)	
		# print("dragged ", card_being_dragged, " to portal to trait discard top")
		card_being_dragged = null # need to do this immedately. 
	elif card_being_dragged != null and portal_to_age_discard_top_found: # age discard top
		if player_hand_reference.player_hand.has(card_being_dragged):
			player_hand_reference.remove_card_from_hand(card_being_dragged) 
		elif opponent_hand_reference.opponent_one_hand.has(card_being_dragged):
			opponent_hand_reference.remove_card_from_hand(card_being_dragged)
		
		age_discard_pile_reference.add_card_to_top(card_being_dragged)
		player_hand_reference.remove_card_from_hand(card_being_dragged) 
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true 
		card_being_dragged.visible = false
		player_hand_reference.update_hand_positions(DEFUALT_CARD_MOVE_SPEED)
		opponent_hand_reference.update_hand_positions(DEFUALT_CARD_MOVE_SPEED)	
		# print("dragged ", card_being_dragged, " to portal to age discard top")
		card_being_dragged = null # need to do this immedately. 
	elif card_slot_found and not card_slot_found.card_in_slot: # # Drag ended at empty slot
		if player_hand_reference.player_hand.has(card_being_dragged):
			player_hand_reference.remove_card_from_hand(card_being_dragged) 
		elif opponent_hand_reference.opponent_one_hand.has(card_being_dragged):
			opponent_hand_reference.remove_card_from_hand(card_being_dragged)
			
		card_being_dragged.position = card_slot_found.position
		# NOTE: this line prevents/stops card from being dragged after being put  
		# into slot. Don't want that
		# card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
		card_being_dragged.card_slot_card_is_in = card_slot_found # video uses this to scale card big in hand small in slot
		# print("Card: ", card_being_dragged, ", ", card_being_dragged.card_slot_card_is_in)
	elif card_being_dragged != null: # drag ended but not at a slot. Then snap back into player's hand
		# pass
		if battle_manager_reference.current_turn == "USER":
			player_hand_reference.add_card_to_hand(card_being_dragged, DEFUALT_CARD_MOVE_SPEED)
		elif battle_manager_reference.current_turn == "OPPONENTONE":
			opponent_hand_reference.add_card_to_hand(card_being_dragged, DEFUALT_CARD_MOVE_SPEED)
		else:
			print("CardManager.gd finish_drag() invalid turn");
	card_being_dragged = null


func connect_card_signal(card):
	card.connect("hovered", on_hovered_over_card) # name of signal(in Card.gd), function we want to connect it to
	card.connect("hovered_off", on_hovered_off_card)


func on_double_click():
	# print("CardManager: on_double_click")
	var card = raycast_check_for_card()
	if (card != null):
		if card.get_node("CardBackImage").z_index > card.get_node("CardImage").z_index:
			card.get_node("AnimationPlayer").play("card_flip_to_front") 
		else:
			card.get_node("AnimationPlayer").play("card_flip_to_back") 


			
	
func on_left_click_released():
	var card_slot_found = raycast_check_for_card_slot()
	var card_found = raycast_check_for_card()
	
	if (current_click_time != -1):
		previous_click_time = current_click_time
	
	current_click_time = Time.get_ticks_msec()
	if current_click_time - previous_click_time < 250:
		# print("Card Manager: on_left_click_released DOUBLE CLICK")
		on_double_click()
	
	# print("Card Manager: on_left_click_released")
	if card_being_dragged != null:
		finish_drag()
	
	# sometimes the game thinks there is a card in a card slot when there isnt
	# I discovered this when mindlessly dragging cards around
	# I would drag a card into a slot, quickly drag it out, then attempt to draw a second card in
	# The game wouln't let me
	# With this change, clicking on a card slot should reset this 
	# Meaning, if you click on a card slot which the computer thinks is filled with a card,
	# but there actually isn't, the card slot will suddenely have a non-negative iq, and realize this
	
	if card_slot_found && not card_found:
		card_slot_found.card_in_slot = false

	
func on_hovered_over_card(card):
	# print("CardManager: called on_hovered_over_card")
	if !is_hovering_on_card:
		is_hovering_on_card = true;
		highlight_card(card, true)

func on_hovered_off_card(card):
	# I didnt do the card slot card being dragged thing	
	
	if !card_being_dragged:
		# if not dragging
		highlight_card(card, false)
		# Check if hovered off card straight onto another card
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered: 
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false; 
	
func highlight_card(card, hovered): #takes a card, and a boolean hovered
	if hovered:
		card.scale = Vector2(HOVERED_CARD_SCALE, HOVERED_CARD_SCALE) # makes card bigger when hovered over
		card.z_index = 2 # card pops out of the screen
	else:
		card.scale = Vector2(BASE_CARD_SCALE, BASE_CARD_SCALE)
		card.z_index = 1


func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent();
	return null

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result) #if two cards are on top of e/o, return the one on top
	return null


# I added
func raycast_check_for_portal_to_trait_deck_top():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_TRAIT_DECK_TOP
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

# end i added

# I added
func raycast_check_for_portal_to_age_deck_top():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_AGE_DECK_TOP
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

# end i added

# I added
func raycast_check_for_portal_to_trait_discard_top():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_TRAIT_DISCARD_PILE_TOP
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

# end i added


# I added
func raycast_check_for_portal_to_age_discard_top():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_AGE_DISCARD_PILE_TOP
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

# end i added


func get_card_with_highest_z_index(cards): # find max of an array I think
	# assume the first card in cards array has the highest z index 
	var highest_z_card = cards[0].collider.get_parent() # object with max
	var highest_z_index = highest_z_card.z_index # cur max
	
	# loop through rest of cards checking for highest z index
	for i in range(1, cards.size()):
		var current_card = cards[1].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
	
