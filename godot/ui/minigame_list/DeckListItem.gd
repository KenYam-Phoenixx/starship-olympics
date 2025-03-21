@tool
extends ColorRect
class_name DeckListItem

@export var CardScene : PackedScene
@export var card_texture : Texture2D
@export var arrow_texture : Texture2D
@export var shuffle_texture : Texture2D
@export var starting_deck: Resource: set = set_starting
var deck: StartingDeck
var index : int: set = set_index

func set_index(v: int) -> void:
	index = v
	$"%Button".set_indentation(index % 2 == 0)

func set_starting(v: StartingDeck):
	if not is_inside_tree():
		await self.ready
	starting_deck = v
	set_deck(starting_deck)

const CARD_SIZE := Vector2(150, 160)

func set_deck(v: StartingDeck) -> void:
	deck = v
	var status = TheUnlocker.get_status("starting_decks", deck.get_id())
	$"%Button".set_label(deck.get_name().to_upper())
	
	if status == TheUnlocker.HIDDEN:
		$"%Button".disabled = true
		$HBoxContainer.modulate = Color(0.6,0.6,0.6)
		$"%Lock".visible = true
		$"%Button".set_label('???')
	else:
		$"%Button".set_image(deck.image)
		
	$"%New".visible = status == TheUnlocker.NEW
	
	var container
	for card in deck.cards:
		container = Container.new()
		container.custom_minimum_size = CARD_SIZE
		$"%HBoxContainer".add_child(container)
		
		var card_node = CardScene.instantiate()
		card_node.scale = Vector2(0.42,0.42)
		card_node.position = CARD_SIZE/2 + Vector2(0, 18)
		card_node.set_content_card(card)
		container.add_child(card_node)
#		if global.has_card_been_shown_from_deck(card.get_id(), deck.get_id()):
		if TheUnlocker.get_status("cards", card.get_id()) == TheUnlocker.UNLOCKED:
			card_node.set_shadow_offset(-32)
			card_node.instant_reveal = true
			card_node.reveal()
		else:
			card_node.position.y -= 26
			card_node.modulate = Color(0.6,0.6,0.6)
		
	container = Container.new()
	container.custom_minimum_size = CARD_SIZE
	$"%HBoxContainer".add_child(container)
	
#	var sprite = Sprite.new()
#
#	if deck.shuffle_before_dealing:
#		sprite.texture = shuffle_texture
#	else:
#		sprite.texture = arrow_texture
#
#	sprite.scale = Vector2(0.2,0.2)
#	sprite.position = CARD_SIZE/2
#	container.add_child(sprite)
#
#	for card in deck.nexts:
#		container = Container.new()
#		container.rect_min_size = CARD_SIZE
#		$"%HBoxContainer".add_child(container)
#
#		var card_node = CardScene.instance()
#		card_node.scale = Vector2(0.25,0.25)
#		card_node.position = CARD_SIZE/2
#		card_node.set_content_card(card)
#		container.add_child(card_node)
#		card_node.instant_reveal = true
#		card_node.reveal()

func grab_focus():
	$"%Button".grab_focus()

func _on_Button_pressed():
	print("{name} has been chosen".format({"name": deck.get_id()}))
	Events.emit_signal("starting_deck_selected", self.deck)
	
func add_flag(who: Dictionary):
	$"%Button".add_flag(who)
	
