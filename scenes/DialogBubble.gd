extends Control

var sfx_text_next = preload("res://sounds/text_next.wav")
var sfx_select = preload("res://sounds/select.wav")
var sfx_scroll = preload("res://sounds/scroll.wav")

@export var sfx_player: AudioStreamPlayer

@export var response_template: Node

@export var name_label: RichTextLabel
@export var text_label: RichTextLabel
@export var responses_menu: VBoxContainer

@export var next_button: Control
@export var previous_button: Control

## The dialogue resource
var resource: Resource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

signal input_next
signal input_previous
signal input_choice(id)
signal choice_hover(id)

# For Circular Debates, the next title to go to when "next" is pressed
var next_line: String:
	set(next_line_text):
		next_button.set_visible(next_line_text != "")
		next_line = next_line_text
	get:
		return next_line

# For Circular Debates, the previous title to go to when "previous" is pressed
var previous_line: String:
	set(previous_line_text):
		previous_button.set_visible(previous_line_text != "")
		previous_line = previous_line_text
	get:
		return previous_line

## The current line
var dialogue_line: Dictionary:
	set(next_dialogue_line):
		is_waiting_for_input = false
		
		if next_dialogue_line.size() == 0:
			return
		
		# Remove any previous responses
		for child in responses_menu.get_children():
			child.free()
		
		dialogue_line = next_dialogue_line
		
		name_label.visible = not dialogue_line.character.is_empty()
		name_label.text = dialogue_line.character
		
		text_label.modulate.a = 0
		text_label.size.x = text_label.get_parent().size.x - 1
		text_label.dialogue_line = dialogue_line
		await text_label.reset_height()

		responses_menu.hide()
		# Show any responses we have
		responses_menu.modulate.a = 0
		if dialogue_line.responses.size() > 0:
			responses_menu.show()
			for response in dialogue_line.responses:
				# Duplicate the template so we can grab the fonts, sizing, etc
				var item: RichTextLabel = response_template.duplicate(0)
				item.name = "Response%d" % responses_menu.get_child_count()
				if not response.is_allowed:
					item.name = String(item.name) + "Disallowed"
					item.modulate.a = 0.4
				item.text = response.text
				item.show()
				responses_menu.add_child(item)

		# Show our balloon
		visible = true
		
		text_label.modulate.a = 1
		if not dialogue_line.text.is_empty():
			text_label.type_out()
			await text_label.finished_typing
		
		# Wait for input
		if dialogue_line.responses.size() > 0:
			responses_menu.modulate.a = 1
			configure_menu()
		elif dialogue_line.time != null:
			var time = dialogue_line.dialogue.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
	get:
		return dialogue_line


func _ready() -> void:
	response_template.hide()
	next_button.hide()
	previous_button.hide()
	hide()

	next_button.pressed.connect(_on_next_pressed)
	previous_button.pressed.connect(_on_previous_pressed)
	DialogueManager.mutation.connect(_on_mutation)


## Start some dialogue
func start(dialogue_resource: Resource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states = extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await DialogueManager.get_next_dialogue_line(resource, title, temporary_game_states)


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await DialogueManager.get_next_dialogue_line(resource, next_id, temporary_game_states)


### Helpers


# Set up keyboard movement and signals for the response menu
func configure_menu() -> void:
	var items = get_responses()
	for i in items.size():
		var item: Control = items[i]
		
		item.focus_mode = Control.FOCUS_ALL
		
		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()
		
		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_previous = item.get_path()
			item.grab_focus()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()
		
		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()
		
		item.focus_entered.connect(_on_response_focus_entered.bind(item))
		item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
		item.gui_input.connect(_on_response_gui_input.bind(item))
		
		if Rect2(Vector2(), item.size).has_point(item.get_local_mouse_position()):
			item.grab_focus()


# Get a list of enabled items
func get_responses() -> Array:
	var items: Array = []
	for child in responses_menu.get_children():
		if "Disallowed" in child.name: continue
		items.append(child)
		
	return items


### Signals


func _on_next_pressed() -> void:
	if not is_waiting_for_input: return

	sfx_player.stream = sfx_text_next
	sfx_player.play()
	emit_signal("input_next")
	next(next_line)


func _on_previous_pressed() -> void:
	if not is_waiting_for_input: return

	sfx_player.stream = sfx_text_next
	sfx_player.play()
	emit_signal("input_previous")
	next(previous_line)


func _on_mutation() -> void:
	is_waiting_for_input = false
#	hide()


func _on_response_focus_entered(item: Control) -> void:
	if "Disallowed" in item.name: return
	sfx_player.stream = sfx_scroll
	sfx_player.play()
	emit_signal("choice_hover", item.get_index())


func _on_response_mouse_entered(item: Control) -> void:
	if "Disallowed" in item.name: return
	item.grab_focus()


func _on_response_gui_input(event: InputEvent, item: Control) -> void:
	if "Disallowed" in item.name: return
	var idx := item.get_index()
	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == 1) or \
	(event.is_action_pressed("ui_accept") and item in get_responses()):
		sfx_player.stream = sfx_select
		sfx_player.play()
		emit_signal("input_choice", idx)
		next(dialogue_line.responses[idx].next_id)


func _unhandled_input(event: InputEvent) -> void:
	if not is_waiting_for_input: return

	if event.is_action_pressed("dialogue_next"):
		sfx_player.stream = sfx_text_next
		sfx_player.play()
		emit_signal("input_next")
		if next_line != "":
			next(next_line)
		else:
			next(dialogue_line.next_id)
	elif event.is_action_pressed("dialogue_previous") and previous_line != "":
		sfx_player.stream = sfx_text_next
		sfx_player.play()
		emit_signal("input_next")
		next(previous_line)
