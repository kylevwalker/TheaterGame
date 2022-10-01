extends Spatial

export(PackedScene) var next_scene
onready var SceneChanger = self.get_parent()

var interacting = false

func _on_Area_area_shape_entered(area_id, area, area_shape, local_shape):
	interacting = true

func _on_Area_area_shape_exited(area_id, area, area_shape, local_shape):
	interacting = false

func _input(event):
	if Input.is_action_just_pressed("interact") && interacting:
		SceneChanger.change_scene(next_scene)
