extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn" # right click on Card.tscn and click copy path
const CARD_DRAW_SPEED = 0.2

var player_age_discard_pile_deck = [] # age deck


var player_hand_reference
var opponent_one_hand_reference
var card_manager_reference
const USER = "USER"
const OPPONENT_ONE = "OPPONENTONE"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# player_deck.shuffle() # suffles deck
	# print("Area 2D collision mask deck: ", $Area2D.collision_mask) 
	$RichTextLabel.text = str(player_age_discard_pile_deck.size()) # cast int to string. Set counter to number of cards in deck 
	player_hand_reference = $"../PlayerHand"
	card_manager_reference = $"../Card Manager"
	opponent_one_hand_reference = $"../OpponentHand"
	
func draw_card(turn, play_animation):
	# print("Drawing Card")
	if  player_age_discard_pile_deck.size() == 0:
		print("age discard pile empty")
		return
		# $Area2D/CollisionShape2D.disabled = true
		# $Sprite2D.visible = false # makes deck sprite invvisible
		# $RichTextLabel.visible = false # makes card counter invisible
	else :
		var card_drawn_name = player_age_discard_pile_deck[0]
		player_age_discard_pile_deck.erase(card_drawn_name)
		$RichTextLabel.text = str(player_age_discard_pile_deck.size()) # cast int to string, cards left in deck
			
		# print("Deck Script: Draw card")
		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()
		var card_image_path = str("res://AgeCardImages/" + card_drawn_name + "Card.png") # name has card at end. Video did this
		new_card.get_node("CardImage").texture = load(card_image_path)
		
		# refrence to card manager. Cards must be children of card manager or else Card script will error
		$"../Card Manager".add_child(new_card) 
		new_card.name = card_drawn_name # he just made it "Card"
		new_card.visible = true
		
		# print(turn)
		if turn == USER:
			$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
		elif turn == OPPONENT_ONE:
			opponent_one_hand_reference.add_card_to_hand(new_card, CARD_DRAW_SPEED)
		else :
			print("invalid turn draw_card Age Discard Pile")
			return
			
		if play_animation:
			# play animation to flip card
			new_card.get_node("AnimationPlayer").play("card_flip_to_front")
	
func add_card_to_top(card):
	# print("add ", card, " to age discard pile top")
	
	# see comments in TraitDeck.gd. Similar thing
	var card_name_without_numbers = card.name.rstrip("0123456789")
	player_age_discard_pile_deck.insert(0, card_name_without_numbers) # player deck only stores names
	
	# in InputManager raycast_check_for_cursor() [draws card], calls draw_card() above, 
	# which draws card at 0 index
	# so I will treat the deck as a STACK with the 0 index being the top and index N-1 being the bottom
	
	card.visible = false
	# print(card.get_node("CardImage"))
	$RichTextLabel.text = str(player_age_discard_pile_deck.size()) # cast int to string
	
	
	# player_hand_reference.remove_card_from_hand(card)
	# remove card from hand is called in finish_drag
	# in finsh drag: if deck is found, remove card from hand and add card to top of deck
	# dont do it again here
	
	# remove_card_from_hand() will update hand positions, dont do it again here
