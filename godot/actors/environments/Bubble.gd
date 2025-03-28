@tool
extends RigidBody2D

class_name Bubblez

signal killed

func get_class():
	return 'Bubble'

const max_group_size = 3
var about_to_pop = false

@onready var radius = $CollisionShape2D.shape.radius

@onready var ChemicalBondScene = preload('res://actors/environments/ChemicalBond.tscn')

@export var owner_player : NodePath
var species : Resource
@export_enum('none', 'square', 'cross', 'triangle', 'circle') var symbol := 'none'
const symbols = ['square', 'cross', 'triangle', 'circle']
const symbol_colors = {
	'none': Color('#929292'),
	'square': Color('#e6e66c'),
	'cross': Color('#8080ff'),
	'triangle': Color('#66ff66'),
	'circle': Color('#ff6666')
}
var color = Color('#929292')

var group = str(get_instance_id())

var points = 1

func _ready():
	add_to_group(group)
	if symbol:
		set_color(symbol_colors[symbol])
	
	$NoRotate/Symbol.texture = load('res://assets/sprites/alchemy/'+symbol+'.png')
	
	# set color if bubble is owned by a player
	await get_tree().idle_frame
	if owner_player:
		set_species(get_node(owner_player).species)

func set_species(v):
	species = v
	set_color(species.color)
	$Particles2D2.modulate = species.color_2
	$NoRotate/Label.text = species.get_monogram()

func set_color(c):
	color = c
	$NoRotate.modulate = color
	$GPUParticles2D.modulate = color
	
func _process(_delta):
	$NoRotate.rotation = -rotation
	#$NoRotate/Label.text = str(points)
	#$NoRotate/Label.text = group
	
func get_color():
	return color
	
func get_group_bubbles():
	return get_tree().get_nodes_in_group(group)
	
func attempt_binding(bubble_shooter):
	await get_tree().create_timer(0.08).timeout
	for bubble in $BindingArea.get_overlapping_bodies():
		if bubble == self or bubble.get_class() != 'Bubble':
			continue
			
		var bond = ChemicalBondScene.instantiate()
		bond.node_a = get_path()
		bond.node_b = bubble.get_path()
		add_child(bond)
		$RandomBindSFX.play()
		
		if species and species == bubble.species or symbol and symbol != 'none' and symbol == bubble.symbol:
			# update all bubbles in current group to join encountered group
			for b in get_group_bubbles():
				if b:
					b.remove_from_group(group)
					b.group = bubble.group
					b.add_to_group(b.group)
					
			# self.group should also have been changed
			
			# update points counter in each member of the new group
			for b in get_group_bubbles():
				b.points = len(get_group_bubbles())
			
			maybe_pop(bubble_shooter) 

func maybe_pop(bubble_shooter):
	await get_tree().create_timer(0.6).timeout # wait a bit to compute all group bindings
	
	if about_to_pop:
		return
	
	# pop all group if max_group_size is reached
	if points >= max_group_size:
		var i = 0
		for b in get_group_bubbles():
			if b:
				b.pop(false, i, bubble_shooter)
				i += 1
	
func pop(now, i=0, bubble_shooter=null):
	about_to_pop = true
	await get_tree().create_timer(i*0.1).timeout # pop in sequence
	$CollisionShape2D.disabled = true
	$AnimationPlayer.play('pop')
	if now:
		$AnimationPlayer.seek(0.3)
	else:
		await get_tree().create_timer(0.5).timeout
	emit_signal('killed', self, bubble_shooter)
	$RandomPopSFX.play()
	await $RandomPopSFX.finished
	await $AnimationPlayer.animation_finished
	queue_free()
	
