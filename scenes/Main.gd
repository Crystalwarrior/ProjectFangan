extends Node


@export var dialogue_resource: Resource
@export var dialogue_title: String = ""
@export var music_player: Node
@export var sfx_player: AudioStreamPlayer
@export var background: Sprite2D
@export var char_sprite: Sprite2D
@export var foreground: Sprite2D
@export var effect_player: AnimationPlayer
@export var dialog_bubble: Node
@export var statement_indicator: Control
@export var evidence_button: Button
@export var evidence_screen: Control


var present_goto = ""
var presented = ""


func _ready():
	dialog_bubble.start(dialogue_resource, dialogue_title)


func sfx(path: String):
	sfx_player.stream = load(path)
	sfx_player.play()


func start_dialogue(path: String, title: String):
	dialog_bubble.dialogue_line = {}
	dialog_bubble.start(load(path), title)

func change_sprite(path: String):
	if path == "":
		char_sprite.texture = null
		return
	char_sprite.texture = load(path)


func change_bg(path: String):
	if path == "":
		background.texture = null
		return
	background.texture = load(path)


func change_fg(path: String):
	if path == "":
		foreground.texture = null
		return
	foreground.texture = load(path)


func change_music(path: String):
	music_player.play_music(load(path))


func set_statements(number: int):
	statement_indicator.set_statements(number)


func select_statement(idx: int):
	statement_indicator.select_statement(idx)


func next_line(title: String):
	dialog_bubble.next_line = title


func previous_line(title: String):
	dialog_bubble.previous_line = title


func add_evidence(evi_name: String, evi_image: String, evi_desc: String):
	evidence_screen.add_evidence(evi_name, evi_image, evi_desc)


# Signals


func _on_evidence_button_pressed():
	evidence_screen.show_screen(present_goto != "")
	evidence_button.set_visible(false)


func _on_evidence_screen_back_pressed():
	evidence_button.set_visible(true)


func _on_evidence_screen_present_pressed(evi_name):
	presented = evi_name
	dialog_bubble.next(present_goto)
	present_goto = ""
	evidence_button.set_visible(true)


func _on_dialog_bubble_input_next():
	pass


func _on_dialog_bubble_input_choice(id):
	pass


func _on_dialog_bubble_choice_hover(id):
	pass


# TODO: Generalize this into a proper effects system
func flash():
	effect_player.play("Flash")

