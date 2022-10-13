extends Node


@export var dialogue_resource: Resource
@export var dialogue_title: String = ""

var present_goto = ""
var presented = ""


func _ready():
	$DialogBubble.start(dialogue_resource, dialogue_title)


func start_dialogue(path, title):
	$DialogBubble.dialogue_line = {}
	$DialogBubble.start(load(path), title)

func change_sprite(path: String):
	if path == "":
		$CharSprite.texture = null
		return
	$CharSprite.texture = load(path)


func change_bg(path: String):
	if path == "":
		$Background.texture = null
		return
	$Background.texture = load(path)


func change_fg(path: String):
	if path == "":
		$Foreground.texture = null
		return
	$Foreground.texture = load(path)


func change_music(path: String):
	$MusicPlayer.play_music(load(path))


func set_statements(number: int):
	$StatementIndicator.set_statements(number)


func select_statement(idx: int):
	$StatementIndicator.select_statement(idx)


func add_evidence(evi_name: String, evi_image: String, evi_desc: String):
	$EvidenceScreen.add_evidence(evi_name, evi_image, evi_desc)


func _on_evidence_button_pressed():
	$EvidenceScreen.show_screen(present_goto != "")
	$EvidenceButton.set_visible(false)


func _on_evidence_screen_back_pressed():
	$EvidenceButton.set_visible(true)


func _on_evidence_screen_present_pressed(evi_name):
	presented = evi_name
	$DialogBubble.next(present_goto)
	present_goto = ""
	$EvidenceButton.set_visible(true)

func start_screen_flash():
	$ScreenFlash/AnimationPlayer.play("Flash")
