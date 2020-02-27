extends Control

onready var disclaimer = $Disclaimer
onready var anim = $AnimationPlayer
onready var skip = $Skip

func _ready():
	set_process_input(false)
	if global.first_time:
		disclaimer.start()
		yield(disclaimer, "okay")
	anim.play("Appear")

func continue():
	get_tree().change_scene(global.from_scene)
	
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene(global.from_scene)