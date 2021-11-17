extends Sprite

var new_position
var new_rotation
## species is a Species Resource needed to setup the battleship
export var species : Resource

func setup(new_pos, new_rot):
	new_position = new_pos
	new_rotation = new_rot

func _process(delta):
	position = lerp(position, new_position, 0.01)
	rotation = lerp(rotation, new_rotation, 0.01)
