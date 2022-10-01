extends Control

onready var text_box = $"Dialog Box/TextureRect/RichTextLabel"
onready var load_words = $"Dialog Box/TextureRect/RichTextLabel/Tween"
onready var sprite_sheet = $"Dialog Box/Sprite Sheet"
onready var parent = get_parent()
onready var scene_node = get_tree()

export(String, FILE, "*.json") var dialogue_file

var dialog = []
var dialog_index = 0
var sprite_index = 0

var is_finished = false
var letter_speed = 52.0

func _ready():
	dialog = load_dialogue_file()	
	
func _input(event):
	if scene_node.paused:
		if Input.is_action_just_pressed("dialog_next"):
			if !is_finished:
				load_words.stop_all()
				is_finished = true
				text_box.percent_visible = 100
			else:
				play_dialog()
		
func play_dialog():
	self.visible = true
	parent.visible = false
	scene_node.paused = true
	
	if dialog_index < dialog.size():
		text_box.percent_visible = 0
		# Testing Sprites
		sprite_index = int(dialog[dialog_index]["pose"])
		sprite_sheet.set_frame(sprite_index)
		is_finished = false
		var text_speed = (dialog[dialog_index]["text"].length() / letter_speed)
		load_words.interpolate_property(text_box, "percent_visible",
		0, 1, text_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		load_words.start()
		var current_line = \
		dialog[dialog_index]["text"]
		text_box.bbcode_text = current_line
		
		dialog_index += 1
			
		
	else:
		dialog_index -= 1
		parent.visible = true
		self.visible = false
		scene_node.paused = false
		
		#queue_free()
		
func _on_Tween_tween_completed(object, key):
	is_finished = true
	
func load_dialogue_file():
	var file = File.new()
	if file.file_exists(dialogue_file):
		file.open(dialogue_file, file.READ)
		return parse_json(file.get_as_text())

