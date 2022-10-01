### The Scene Dialog manager must be a parent of NPCS tab, with
### all Npcs parented to this tab. NPCS reference this script
### as parent.parent, and this cript uses node path names
### to access specific NPC names. NPC names must match JSON
### file naming: "Venezia, Leo, Charlotte," etc

extends Control

onready var text_box = $"Canvas2/Dialog Box/TextureRect/DialogText"
onready var load_words = $"Canvas2/Dialog Box/TextureRect/DialogText/Tween"
onready var name_tag = $"Canvas2/Dialog Box/TextureRect/NameTag"
onready var scene_node = get_tree()
onready var player = GameManager.player_node
onready var player_cam = player.get_node("Rotation")

const LOOKAT_OFFSET = 4
const LOOKAT_SPEED = 0.1
const ROTATION_SMOOTHING = 12

export(String, FILE, "*.json") var dialogue_file
export(int) var start_index	#Initial starting index
export(int) var end_index	#Initial ending index

var dialog = [] 		#Array of text in Json
var dialog_index = 0	#Current index of dialog array
var ending_index		#Current ending index based on conversation
var sprite_index = 0	#Current sprite index
var cur_char			#Reference to current NPC
var char_model			#Model of current npc
var sprite_sheet
var active = false
var player_start_view = Vector3()
var look_target_start = Vector3()

var is_finished = false
var letter_speed = 66.0

signal dialog_finished

func _ready():
	set_process(false)
	dialog = load_dialogue_file()	
	toggle_visibility(false)
	player_start_view = player_cam.rotation
	
func load_dialogue_file():
	var file = File.new()
	if file.file_exists(dialogue_file):
		file.open(dialogue_file, file.READ)
		return parse_json(file.get_as_text())	

func _process(delta):
	# look to current character while talking
	look_at_char(char_model, delta)

func _input(event):
	if active:
		if Input.is_action_just_pressed("dialog_next"):
			if !is_finished:
				# Force load all text for current box
				load_words.stop_all()
				is_finished = true
				text_box.percent_visible = 100
			else:
				# Play next line in dialog
				play_dialog(dialog_index, ending_index)
		
func play_dialog(start_index, end_index):
	### ACTIVATES DIALOG AND DEACTIVATES PLAYER CONTROLS
	if ! active:
		print("Starting Dialog")
		GameManager.updateGameState(GameManager.gameState.STORY_MODE)
		set_process(true)
		toggle_visibility(true)
		active = true
		dialog_index = start_index
		ending_index = end_index
	
	if dialog_index <= end_index:
	### STORES CURRENT CHARACTER< POSE< AND TEXT FROM JSON
		var prev_char = cur_char
		cur_char = "NPCS/" + dialog[dialog_index]["char"]
		# Disables previous sprite sheet and enable prev model 
		if prev_char != cur_char && prev_char != null:
			var prev_sprite_sheet = get_node(prev_char + "/Canvas/Dialog Sprites")
			prev_sprite_sheet.visible = false
			var prev_char_model = get_node(prev_char)
			prev_char_model.visible = true
		var cur_pose = dialog[dialog_index]["pose"]
		var cur_text = dialog[dialog_index]["text"]
		char_model = get_node(cur_char)
		text_box.percent_visible = 0
		change_sprite(cur_pose)
		print_dialog(cur_text)
	
	else:
		print("Exiting Dialog")
		exit_dialog()

func print_dialog(cur_text):
	is_finished = false
	var cur_name = dialog[dialog_index]["char"]
	name_tag.bbcode_text = cur_name
	var text_speed = (cur_text.length() / letter_speed)
	load_words.interpolate_property(text_box, "percent_visible",
	0, 1, text_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	load_words.start()
	text_box.bbcode_text = cur_text
	dialog_index += 1

func change_sprite(cur_pose):
	char_model.visible = false
	sprite_sheet = get_node(cur_char + "/Canvas/Dialog Sprites")
	sprite_sheet.visible = true
	sprite_sheet.get_child(0).set_frame(int(cur_pose))

func look_at_char(char_model, delta):
	var target_view = char_model.get_global_transform().origin
	target_view.y += LOOKAT_OFFSET 
	var player_global = player_cam.get_global_transform()
	var target_rotation = \
		player_global.looking_at(target_view, Vector3.UP)
	player_cam.global_transform = \
		player_global.interpolate_with(target_rotation, delta * ROTATION_SMOOTHING)
	
func toggle_visibility(mode:bool):
	var canvas1 = get_child(0).get_child(0)
	var canvas2 = get_child(1).get_child(0)
	if mode == true:
		canvas1.visible = true
		canvas2.visible = true
	else:
		canvas1.visible = false
		canvas2.visible = false

func exit_dialog():
	#self.visible = false
	toggle_visibility(false)
	sprite_sheet.visible = false
	char_model.visible = true
	active = false
	player_cam.rotation = player_start_view
	set_process(false)
	GameManager.rewindGameState()
		
func _on_Tween_tween_completed(object, key):
	is_finished = true
	



