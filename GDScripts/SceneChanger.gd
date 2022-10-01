extends CanvasLayer

signal scene_changed()
onready var anim_player = $Control/Black/AnimationPlayer
onready var canvas = $Control/Black

func change_scene(path):
	PauseMenu.can_pause = false
	anim_player.play("fade")
	yield(anim_player, "animation_finished")
	get_tree().change_scene_to(path)
	anim_player.play_backwards("fade")
	PauseMenu.can_pause = true
