extends Node2D
const CARD_SCENE_PATH = "res://Scenes/Card.tscn" # right click on Card.tscn and click copy path
const CARD_DRAW_SPEED = 0.2
const NUM_CATASTROPHES = 4;

# deck of non-catastrophes
var all_ages_deck = [
	"AgeOfPeace", "GlacialDrift", "HighTides", "LunarRetreat", "NorthernWinds",
	"AgeOfWonder", "AlienTerraform", "Awakening", "GalacticDrift", "BirthOfAHero",
	"CoastalFormations", "Flourish", "NaturalHarmony", "Prosperity", "Reforestation",
	"TectonicShift", "TropicalLands", "AgeOfDracula", "AgeOfNietzsche", "Eclipse", 
	"Enlightenment", "AgeOfReason", "AridLands", "CometShowers", "TheMessiah"
]

var all_catastrophes_deck = [
	"TheBigOne", "DeusExMachina", "Overpopulation", "GlacialMeltdown", "IceAge",
	"MegaTsunami", "TheFourHorsemen", "GreyGoo", "MassExtinction", "NuclearWinter",
	"SolarFlare", "SuperVolcano", "AITakeover", "PulseEvent", "Retrovirus",
]


var player_age_deck = [] # age deck
var temp_deck = [];

var player_hand_reference
var opponent_one_hand_reference
var card_manager_reference
const USER = "USER"
const OPPONENT_ONE = "OPPONENTONE"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# player_deck.shuffle() # suffles deck
	# print("Area 2D collision mask deck: ", $Area2D.collision_mask) 
	
	#TODO Shuffle deck coomlings style
	# player_age_deck = all_catastrophes_deck;
	var temp_index = -1;
	for i in range(0, NUM_CATASTROPHES):
		# function documentation: int randi_range(from: int, to: int), inclusive on both ends
		# select 3 ages and put them in the array temp
		for j in range(0, 3):
			# print(all_ages_deck.size())
			if (all_ages_deck.size() == 0):
				print("AgeDeck.gd no more ages to add to age deck");
				$RichTextLabel.text = str(player_age_deck.size())
				return;
				
			temp_index = randi_range(0, all_ages_deck.size() - 1);
			temp_deck.append(all_ages_deck[temp_index]);
			all_ages_deck.erase(all_ages_deck[temp_index]);
		
		if (all_catastrophes_deck.size() == 0):
				print("AgeDeck.gd no more catatrophes to add to age deck");
				$RichTextLabel.text = str(player_age_deck.size())
				return;
		
		# select 1 catastrophe and put it in the array temp
		temp_index = randi_range(0, all_catastrophes_deck.size() - 1);
		temp_deck.append(all_catastrophes_deck[temp_index]);
		all_catastrophes_deck.erase(all_catastrophes_deck[temp_index]);
		
		# shuffle this array BUT we want the bottom one to be a catastrophe
		if (i != NUM_CATASTROPHES - 1):
			temp_deck.shuffle();
		
		
		# append it to player_age_deck
		player_age_deck += temp_deck
		
		# clear the temp deck
		temp_deck.clear();
	player_age_deck.insert(0, "TheBirthOfLife");
	
	
	
	$RichTextLabel.text = str(player_age_deck.size()) # cast int to string. Set counter to number of cards in deck 
	player_hand_reference = $"../PlayerHand"
	card_manager_reference = $"../Card Manager"
	opponent_one_hand_reference = $"../OpponentHand"
	
	
func draw_card(turn, play_animation):
	# print("Drawing Card")
	if  player_age_deck.size() == 0:
		print("age deck empty")
		return
		# $Area2D/CollisionShape2D.disabled = true
		# $Sprite2D.visible = false # makes deck sprite invvisible
		# $RichTextLabel.visible = false # makes card counter invisible
	else :
		var card_drawn_name = player_age_deck[0]
		player_age_deck.erase(card_drawn_name)
		$RichTextLabel.text = str(player_age_deck.size()) # cast int to string, cards left in deck
			
		# print("Deck Script: Draw card")
		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()
		var card_image_path = str("res://AgeCardImages/" + card_drawn_name + "Card.png") # name has card at end. Video did this
		new_card.get_node("CardImage").texture = load(card_image_path)
		
		$"../Card Manager".add_child(new_card) # refrence to card manager. Cards must be children of card manager or else Card script will error
		new_card.name = card_drawn_name # he just made it "Card"
		new_card.visible = true
		
		# print("AgeDeck script. turn: ", turn)
		# print ("AgeDeck script. does turn == USER? ", turn == USER)
		if turn == USER:
			$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
		elif turn == OPPONENT_ONE:
			opponent_one_hand_reference.add_card_to_hand(new_card, CARD_DRAW_SPEED)
		else :
			print("invalid turn draw_card Age Deck")	
			return
			
		if play_animation:
			# play animation to flip card
			new_card.get_node("AnimationPlayer").play("card_flip_to_front") 
	
func add_card_to_top(card):
	# print("AgeDeck: add ", card, " to age deck top")
	
	# see comments in TraitDeck.gd. Similar thing
	var card_name_without_numbers = card.name.rstrip("0123456789")
	player_age_deck.insert(0, card_name_without_numbers) # player deck only stores names
	
	# in InputManager raycast_check_for_cursor() [draws card], calls draw_card() above, 
	# which draws card at 0 index
	# so I will treat the deck as a STACK with the 0 index being the top and index N-1 being the bottom
	
	card.visible = false
	# print(card.get_node("CardImage"))
	$RichTextLabel.text = str(player_age_deck.size()) # cast int to string
	
	
	# player_hand_reference.remove_card_from_hand(card)
	# remove card from hand is called in finish_drag
	# in finsh drag: if deck is found, remove card from hand and add card to top of deck
	# dont do it again here
	
	# remove_card_from_hand() will update hand positions, dont do it again here
