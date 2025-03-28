extends Node2D

class_name Barz

@export var cpu_ship_texture : Texture2D

const max_bar_width = 950
const bar_height = 20
const ministar_width = 20
const offset_left = 50
const offset_top = 10
const streak_arrow_width = 8
const black_border = 1
const fake_3d = 3
var max_score

const Star = preload('res://special_scenes/combat_UI/session_points/Star.tscn')

@onready var sprite = $Ship/Sprite2D

@onready var ministar_margin = ministar_width * global.win

var player
var new_position : set = change_position
var current_value = 0
var previous_value = 0
var author: InfoPlayer

var streaking = false
var current_streak_bar
var streak_start
var streaks_enabled := true

func post_ready(p: InfoPlayer):
	player = p
	var species = player.species
	max_score = global.the_match.target_score
	
	$Streaks.visible = streaks_enabled
	
	if player.is_cpu():
		sprite.texture = cpu_ship_texture
		sprite.modulate = player.get_color()
	else:
		sprite.texture = species.ship
		sprite.modulate = Color.WHITE
	
	# background
	$Background.position = Vector2(offset_left, offset_top)
	$Background.size = Vector2(max_bar_width - ministar_margin, bar_height)
	$Background.color = player.get_color()
	
	$BlackBackground.position = Vector2(offset_left-black_border, offset_top-black_border)
	$BlackBackground.size = Vector2(max_bar_width - ministar_margin + 2*black_border, bar_height + 2*black_border)
	
	$Background25D.position = Vector2(offset_left-black_border, offset_top+bar_height-fake_3d)
	$Background25D.size = Vector2(max_bar_width - ministar_margin + 2*black_border, fake_3d)
	
	# megabar
	$MegaBar.color = player.get_color()
	if not streaks_enabled:
		$MegaBar.modulate = Color.WHITE
	
	# ship and score
	$Ship.position.x = offset_left
	$Ship/ScoreLabel.modulate = player.get_color()
	
	# max score
	$MaxScoreLabel.text = str(max_score)
	$MaxScoreLabel.modulate = player.get_color()
	$MaxScoreLabel.position = Vector2(offset_left + max_bar_width - ministar_margin + black_border - 48, offset_top-black_border+2)
	
	# magenta max score if perfectionist mode enabled
	var current_draft_card := global.the_match.get_draft_card()
	if current_draft_card != null and current_draft_card.is_perfectionist():
		$MaxScoreLabel.modulate = Color('#ff40d4')
		$MaxScoreLabel.self_modulate = Color(1,1,1,1)
	
	# ticks
	for i in range(1, int(max_score)):
		# skip some ticks according to max score's order of magnitude
		if max_score > 99 and i%10 != 0:
			continue
		
		var tick = Line2D.new()
		var opacity = 0.8 if max_score <= 10 or (i%10 == 0 and max_score < 100) or i%100 == 0 else 0.2
		tick.default_color = Color(0,0,0,opacity)
		tick.width = 3
		var x = round((max_bar_width - ministar_margin) / max_score * i)
		tick.points = PackedVector2Array([Vector2(offset_left+x, offset_top), Vector2(offset_left+x, offset_top+bar_height)])
		$Ticks.add_child(tick)
	
	# mini stars
	for i in range(global.win):
		var star = Star.instantiate()
		star.scale = Vector2(0.18,0.18)
		star.position.x = offset_left + max_bar_width - ministar_margin + i*ministar_width + 18
		star.position.y = 18
		add_child(star)
		
	update_stars()
	set_value(p.stats.score, p)
	
func update_stars():
	var stars = []
	for node in get_children():
		if node is StarIcon:
			stars.append(node)
			
	for i in range(global.win):
		if i < len(player.session_score):
			stars[i].won = true
			stars[i].perfect = player.session_score[i].perfect
	
func set_value(value: float, new_author: InfoPlayer):
	$Ship/ScoreLabel.text = str(floor(value))
	
	if value == current_value:
		return
		
	author = new_author
	
	previous_value = current_value
	current_value = clamp(value, 0, max_score)
	
	$Ship.position.x = offset_left + (max_bar_width - ministar_margin) / max_score * current_value
	
	if current_value != previous_value:
		streak_on()
		
func get_value():
	return current_value

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()
	
func streak_on():
	if not streaking:
		streaking = true
		add_streak_bar()
	$StreakTimer.start(0.5)
	update_current_streak_bar()
	update_megabar()
	
func streak_off():
	streaking = false
	
	# stop glowing for older bars
	if current_streak_bar != null:
		current_streak_bar.color = author.get_color()

func _on_StreakTimer_timeout():
	streak_off()

func add_streak_bar():
	current_streak_bar = Polygon2D.new()
	
	# glow
	current_streak_bar.material = CanvasItemMaterial.new()
	current_streak_bar.color = GlowColor.new(author.get_color(), 1.15).color
	
	streak_start = previous_value
	$Streaks.add_child(current_streak_bar)
	
func update_current_streak_bar():
	var left = offset_left + (max_bar_width - ministar_margin) / max_score * streak_start
	var right = offset_left + (max_bar_width - ministar_margin) / max_score * current_value
	var actual_arrow_width = max(0,min(right-left, streak_arrow_width)) # negative streaks have no arrow
	current_streak_bar.polygon = PackedVector2Array([
		Vector2(left, offset_top+bar_height),
		Vector2(left, offset_top),
		Vector2(right-actual_arrow_width, offset_top),
		Vector2(right, offset_top+bar_height/2),
		Vector2(right-actual_arrow_width, offset_top+bar_height)
	])
	# darken the streak if it's negative
	if right < left:
		current_streak_bar.modulate = Color(0,0,0,0.8)
	
func update_megabar():
	var right = offset_left + (max_bar_width - ministar_margin) / max_score * current_value
	$MegaBar.polygon = PackedVector2Array([
		Vector2(offset_left, offset_top+bar_height),
		Vector2(offset_left, offset_top),
		Vector2(max(offset_left,right-streak_arrow_width), offset_top),
		Vector2(right, offset_top+bar_height/2),
		Vector2(max(offset_left,right-streak_arrow_width), offset_top+bar_height)
	])
	
