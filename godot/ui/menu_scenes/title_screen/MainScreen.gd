extends Control

func _ready():
	Soundtrack.play("Lobby", true)
	# TranslationServer.set_locale("es")
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Label.text = tr("DEMO BUILD - v"+ str(global.version))
	$"%Info".text = "Sessions played: {sessions_played}. Decks unlocked: {unlocked} \n Press SHIFT+R to reset".format({"sessions_played": global.sessions_played, "unlocked": TheUnlocker.get_unlocked_list("starting_decks")})

func _process(delta):
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_R):
		global.sessions_played = 0
		# TheUnlocker.unlock_element("starting_decks", "winter", TheUnlocker.LOCKED)
		TheUnlocker.reset_unlocks()
		$"%Info".text = "Sessions played: {sessions_played}. Decks unlocked: {unlocked} \n Press SHIFT+R to reset".format({"sessions_played": global.sessions_played, "unlocked": TheUnlocker.get_unlocked_list("starting_decks")})
		persistance.save_game()
