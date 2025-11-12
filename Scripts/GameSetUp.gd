extends Node2D



func host_set_up():
	# He sets player and opponent health
	get_parent().get_node("PlayerField/TraitDeck/RichTextLabel").text = str(get_parent().get_node("PlayerField/TraitDeck").trait_deck.size())    
	
	# Enable end turn button. Enable inputs
	# await $TraitDeck.draw_initial_hand()
	
	$EndTurnButton.visible = true
	$EndTurnButton.disabled = false
	
	$InputManager.inputs_disabled = false
	
	


func client_set_up():
	pass
	# He sets player and opponent health
	# get_parent().get_node("OpponentOneField/TraitDeckOpponentOne").deck_size = 8 # can change
	# get_parent().get_node("OpponentOneField/TraitDeckOpponentOne/RichTextLabel").text = "8" # can change
	# $TraitDeck.draw_initial_hand()
