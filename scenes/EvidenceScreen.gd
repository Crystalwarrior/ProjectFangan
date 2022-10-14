extends Control

# TODO: keep evidence array in a global instead of UI
var evidence_array := []
var can_present = false
var placeholder_image = preload("res://evidence/Unknown.png")
var sfx_paper_up = preload("res://sounds/paper_up.wav")
var sfx_paper_down = preload("res://sounds/paper_down.wav")
var sfx_select = preload("res://sounds/select.wav")
var sfx_scroll = preload("res://sounds/scroll.wav")

@export var present_button: Button
@export var back_button: Button

@export var evidence_list: ItemList
@export var evidence_image: TextureRect
@export var evidence_desc: RichTextLabel

@export var sfx_player: AudioStreamPlayer

signal back_pressed
signal present_pressed(evi_name)

func _ready():
	evidence_list.item_selected.connect(_on_item_selected)
	back_button.pressed.connect(_on_back_pressed)
	present_button.pressed.connect(_on_present_pressed)


func add_evidence(evi_name: String, evi_image: String, evi_desc: String):
	var evi: Dictionary = {"name": evi_name, "image": evi_image, "desc": evi_desc}
	evidence_array.append(evi)
	evidence_list.add_item(evi["name"], load(evi["image"]))


func remove_evidence(evi_name: String):
	for i in range(evidence_array.size()):
		var evi = evidence_array[i]
		if evi["name"] == evi_name:
			evidence_array.remove_at(i)
			evidence_list.remove_item(i)
			break


func clear_evidence():
	evidence_array.clear()


func populate_evidence_list():
	evidence_list.clear()
	for evi in evidence_array:
		evidence_list.add_item(evi["name"], load(evi["image"]))


func show_screen(_can_present: bool):
	set_visible(true)
	self.can_present = _can_present
	present_button.set_disabled(not evidence_list.is_anything_selected() or not can_present)
	sfx_player.stream = sfx_paper_up
	sfx_player.play()


func _on_item_selected(idx: int):
	evidence_image.texture = load(evidence_array[idx]["image"])
	evidence_desc.text = evidence_array[idx]["desc"]
	present_button.set_disabled(not evidence_list.is_anything_selected() or not can_present)
	sfx_player.stream = sfx_scroll
	sfx_player.play()

func _on_back_pressed():
	set_visible(false)
	emit_signal("back_pressed")
	sfx_player.stream = sfx_paper_down
	sfx_player.play()

func _on_present_pressed():
	set_visible(false)
	emit_signal("present_pressed", evidence_array[evidence_list.get_selected_items()[0]]["name"])
	sfx_player.stream = sfx_paper_down
	sfx_player.play()
