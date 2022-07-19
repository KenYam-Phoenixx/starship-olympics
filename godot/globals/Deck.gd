extends Node

class_name Deck

var cards : Array = []
var played_pile : Array = []
var card_pool : CardPool
var next : Array = []

const DECK_PATH = "res://map/draft/"
const CARD_POOL_PATH = "res://map/draft/pool"

func _init():
	randomize()
	# we might decide to put this in a 
	var decks = global.get_resources(DECK_PATH)
	var unlocked_decks = TheUnlocker.get_unlocked_list("starting_decks")
	var starting_deck: StartingDeck = global.get_actual_resource(decks, unlocked_decks[0])
	append_cards(starting_deck.minigames)
	
	var pools = global.get_resources(CARD_POOL_PATH)
	var unlocked_pools = TheUnlocker.get_unlocked_list("card_pools")
	card_pool = global.get_actual_resource(pools, unlocked_pools[0])
	
	prepare_next_cards(['board_conquest', 'ark_of_memory'])
	
# could return less than the number of requested cards in corner cases
func draw(how_many : int) -> Array:
	# reshuffe the played pile into the deck if the deck is emptied
	if how_many > len(cards):
		print('deck is about to be emptied (' + str(len(cards)) + ' left, ' + str(how_many) + ' requested).')
		print('reshuffling ' + str(len(played_pile)) + ' cards from the played pile.')
		print(played_pile)
		append_cards(played_pile)
		played_pile = []
		shuffle()
		print('deck now contains ' + str(len(cards)) + ' cards')
		print(cards)
		
	var result = []
	for i in range(how_many):
		var card = cards.pop_front()
		if card != null:
			result.append(card)
	return result
	
func shuffle():
	cards.shuffle()
	for card in cards:
		card.new = false
	
# add cards to the deck
func append_cards(cards_to_be_appended : Array) -> void:
	cards.append_array(cards_to_be_appended)
	
func add_new_cards(amount := 1) -> void:
	next.shuffle()
	var new_cards = []
	for i in range(amount):
		var new_card = next.pop_front()
		if new_card != null:
			new_card.new = true
			new_cards.append(new_card)
			
	new_cards.shuffle()
	cards = new_cards + cards # new cards are placed on top

func put_card_into_played_pile(card) -> void:
	played_pile.append(card)
	
func prepare_next_cards(next_card_ids) -> void:
	if len(next_card_ids) <= 0:
		return
		
	next_card_ids.shuffle()
	
	var next_cards = []
	for id in next_card_ids:
		if not card_pool.has(id):
			print("Skipping duplicate: " + id)
			continue
		
		var card = card_pool.retrieve_card(id)
		if card == null:
			continue
		
		next.append(card)
	
