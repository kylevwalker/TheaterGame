extends Spatial

onready var player = get_parent().get_node("Player")
onready var camera = player.get_node("Rotation")

const OFFSET_Y = 4.5
var offset = Vector3(0,0,-1)

func _process(delta):
	self.rotation_degrees = Vector3(camera.rotation_degrees.x,
	player.rotation_degrees.y, 0)
	
	self.translation = Vector3(player.translation.x,
		player.translation.y + OFFSET_Y, player.translation.z)
	
	self.translate(offset)
