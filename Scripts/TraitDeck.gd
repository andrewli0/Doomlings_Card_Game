extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn" # right click on Card.tscn and click copy path
const CARD_DRAW_SPEED = 0.2
const STARTING_HAND_SIZE = 0

var trait_deck = [
	"Echolocation", "Immunity", "Tiny", "Automimicry", "Blubber",
	"Chromatophores", "ColdBlood", "CostlySignaling", "EggClusters", "Flight",
	"Gills", "IridescentScales", "Migratory", "PaintedShell", "RegenerativeTissue",
	"Saliva", "Scutes", "SelectiveMemory", "Spiny", "Sweat",
	"Tentacles", "Heroic", "PackBehavior", "Symbiosis", "Appealing",
	"Bark", "Branches", "DeepRoots", "Fecundity", "Fortunate",
	"Leaves", "Overgrowth", "Photosynthesis", "Pollination", "Propogation",
	"RandomFertilization", "SelfReplicating", "Swarm", "Swarm", "Swarm",
	"Swarm", "Swarm", "TinyLittleMelons", "Trunk", "WoodyStems",
	"Denial", "Faith", "OptimisticNihilism", "Altruistic", "Boredom",
	"Confusion", "Delicious", "Doting", "Eloquence", "Fear",
	"Flatulence", "Gratitude", "Introspective", "Just", "Late",
	"Mindful", "Mitochondrion", "Morality", "Prepper", "Saudade",
	"Self-Awareness", "TheThirdEye", "Camouflage", "Vampirism", "Viral",
	"Adorable", "BigEars", "Clever", "DirectlyRegister", "Dreamer",
	"FineMotorSkills", "Impatience", "Inventive", "Memory", "Nocturnal",
	"Nosy", "Parasitic", "Persuasive", "Poisonous", "Selfish", 
	"Sneaky", "StickySecretions", "SuperSpreader", "Teeth", "Telekinetic",
	"Venomous", "ApexPredator", "Hyper-Intelligence", "Sentience", "Antlers",
	"Bad", "Brave", "BruteStrength", "Endurance", "Fangs",
	"FireSkin", "HeatVision", "HotTemper", "Kidney", "Kidney",
	"Kidney", "Kidney", "Kidney", "Kidney", "Quick",
	"Reckless", "RetractableClaws", "StoneSkin", "Territorial", "Voracious",
	"WarmBlood"
	
	
	
]

var trait_card_database_reference

var timer
var player_hand_reference
var opponent_one_hand_reference
var card_manager_reference
var trait_deck_opponent_one_node

const USER = "USER"
const OPPONENT_ONE = "OPPONENTONE"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = $"../BattleTimer"
	timer.one_shot = true # so the timer doenst loop over and over
	timer.wait_time = 1.0 # 1 second
	$RichTextLabel.text = str(trait_deck.size())
	# draw 5 cards into each players hand
	for i in range(STARTING_HAND_SIZE):
		draw_card(USER, true)
		draw_card(OPPONENT_ONE, false)
		
	# cards are automatically flipped face up when drawn to hand in draw_card function
	# but at the beginning of the game, we should not see the opponent's cards.
	# must flip them back
	opponent_one_hand_reference = $"../OpponentHand"
	#for card in opponent_one_hand_reference.opponent_one_hand:
		#print("Card front z_index: ", card.get_node("CardImage").z_index)
		#print("Card back z_index: ", card.get_node("CardBackImage").z_index)
		#var temp = card.get_node("CardBackImage").z_index 
		#card.get_node("CardBackImage").z_index = card.get_node("CardImage").z_index
		#card.get_node("CardImage").z_index = temp
		#print("Card front z_index: ", card.get_node("CardImage").z_index)
		#print("Card back z_index: ", card.get_node("CardBackImage").z_index)
		## card.get_node("AnimationPlayer").play("card_flip_to_back") 
	

func draw_card(turn, play_animation):
	# turn is USER or OPPONENT_ONE
	#signifies which hand to draw card into, USER's or OPPONENT_ONE's
	print ("Drawing Card Trait Deck")
	wait(1.0)
	if  trait_deck.size() == 0:
		print("trait deck empty")
		return
		# $Area2D/CollisionShape2D.disabled = true
		# $Sprite2D.visible = false # makes deck sprite invvisible
		# $RichTextLabel.visible = false # makes card counter invisible
	else :
		var card_drawn_name = trait_deck[0]
		
		trait_deck.erase(card_drawn_name)
		$RichTextLabel.text = str(trait_deck.size())
		# print("Deck Script: Draw card")
		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()
		var card_image_path = str("res://TraitCardImages/" + card_drawn_name + "Card.png") # name has card at end. Video did this
		new_card.get_node("CardImage").texture = load(card_image_path)
		
		 # refrence to card manager. Cards must be children of card manager or else Card script will error
		$"../Card Manager".add_child(new_card)
		new_card.name = card_drawn_name # he just made it "Card"
		new_card.visible = true
		# print("TraitDeck.gd: turn: ", turn)
		
		
		
		if turn == USER:
			$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
			print("Drew ", new_card.name, " into USER hand")
		elif turn == OPPONENT_ONE:
			$"../OpponentHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
			print("Drew card into OPPONENTONE hand")
		else:
			print("invalid turn draw_card Trait Deck")	
			return
			
		# play animation to flip card
		if play_animation:
				new_card.get_node("AnimationPlayer").play("card_flip_to_front") 


func add_card_to_top(card):
	# print("add ", card, " to trait pile top")
	
	# problem:
	# Say the deck contains only 1 card: Pack Behavior
	# Say I draw pack behavior and put it through the portal to deck top
	# Then the name of the card I sent through portal is "PackBehavior"
	# If I draw pack behavior again, and put it through the top, the name is "PackBehavior2"
	# Then when I try and draw Pack Behavior again, no such image with "PackBehavior2Card" can be found
	# This causes the card_image_path = str(blahblahblah+Card.png) line to fail
	# We need to strip the numbers off the end
	var card_name_without_numbers = card.name.rstrip("0123456789")
	trait_deck.insert(0, card_name_without_numbers) # player deck only stores names
	$RichTextLabel.text = str(trait_deck.size())
	
	# in InputManager raycast_check_for_cursor() [draws card], calls draw_card() above, 
	# which draws card at 0 index
	# so I will treat the deck as a STACK with the 0 index being the top and index N-1 being the bottom
	
	card.visible = false
	# print(card.get_node("CardImage"))
	
	
	# player_hand_reference.remove_card_from_hand(card)
	# remove card from hand is called in finish_drag
	# in finsh drag: if deck is found, remove card from hand and add card to top of deck
	# dont do it again here
	
	# remove_card_from_hand() will update hand positions, dont do it again here

# I added
func wait(wait_time):
	timer.wait_time = wait_time
	timer.start()
	await timer.timeout
