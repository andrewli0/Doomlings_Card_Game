extends Node2D

signal hovered
signal hovered_off

var position_in_hand: Vector2 # video uses starting_position
var card_slot_card_is_in # video uses this for scaling the card big in hand and small in slot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All cards must be a child of CardManager (else throw error) (this is called anytime a card is constructed). 
	# print("Opponent card parent: ", get_parent(), ", ", get_parent())
	# get_parent().connect_card_signals(self)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self) # self is the card that was hovered over


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self) # self is the card that was hovered over
