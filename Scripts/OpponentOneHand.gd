extends Node2D

const CARD_WIDTH = 155 # can make cards closer together than when in player hand 
var HAND_Y_POSITION #  = 890, not actually using 890
const DEFUALT_CARD_MOVE_SPEED = 0.2
const BASE_CARD_SCALE = 0.55
const HOVERED_CARD_SCALE = 0.9 # 0.65 # make 1 so can read the card

var opponent_one_hand = []
var center_screen_x

# video #4 uses var total_width insetad of x_offset
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var opponent_one_hand_path = self.get_path()
	# print ("Opponent One Hand Path: ", self.get_path())
	center_screen_x = get_viewport().size.x/2.2  # width of screen/2


func add_card_to_hand(card, speed):
	# called in 2 places: ready function when nothing in hand
	# 1. Card ready function above when card hasn't been added to hand yet
	# 2. CardManager finishDrag(), dropping card into player hand (card is already in hand) -> move it back
	if card not in opponent_one_hand: # case 1
		opponent_one_hand.insert(opponent_one_hand.size(), card) # insert card into last element of array
		# player_hand.insert(0, card) # insert card into first element of array
		# print("add_card_to_hand is calling update_card_positions")
		update_hand_positions(speed)
		# print("player_hand size: add_card_to_hand() ", player_hand.size())
	else : # case 2
		animate_card_to_position(card, card.position_in_hand, DEFUALT_CARD_MOVE_SPEED) # video used starting_position, not position_in_hand
	
func update_hand_positions(speed):
	print("Called Opponent update_hand_positions(), hand size: ", opponent_one_hand.size())
	for i in range(opponent_one_hand.size()):
		# get new card position based on how many cards in hand
		# Card should be drawn to top of screen, not bottom
		var HAND_Y_POSITION = get_viewport().get_visible_rect().size.y*0.075
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = opponent_one_hand[i] # card we want to move
		card.position_in_hand = new_position # video uses starting_position, not position_in_hand
		animate_card_to_position(card, new_position, speed)
		card.scale = Vector2(BASE_CARD_SCALE, BASE_CARD_SCALE)

func calculate_card_position(index):
	# print("calculate_card_position player_hand_size: ", player_hand.size())
	var x_offset = (opponent_one_hand.size() - 1) * CARD_WIDTH # video names var total_width
	# print("x_offset: ", x_offset)
	
	# make the hand a bit more to the left so can fit another player's hand somewhere
	# so center_screen_x divided by 2 instead of center_screen_x
	var x_position = center_screen_x/2 - (index * CARD_WIDTH) + (x_offset)
	# if minus (index...) then plus (x_offset/2), card draws to left of players hand (from my persepctive)
	
	# print("x_position: ", x_position)
	return x_position # video #4 returns x_offset, which is wrong I think
	

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()  #Tween: "Lightweight object used for general-purpose animation via script, using Tweeners.
	tween.tween_property(card, "position", new_position, speed) # object, property we are changing, new position, speed of animation
	
	
func remove_card_from_hand(card):
	# interate through index, use array.remove_at(index)
	var i = 0
	while i < len(opponent_one_hand):
		if opponent_one_hand[i] == card:
			
			opponent_one_hand.remove_at(i)
			# print("player hand size after removing: ", player_hand.size())
			
			# print("remove_card_from_hand is calling update_hand_positions")
			update_hand_positions(DEFUALT_CARD_MOVE_SPEED)
		i = i + 1 # FORGOT THIS STUPID STUPID STUPID
	
