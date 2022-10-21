extends Control


@onready var rule_container = $RuleContainer
@onready var sfx_player = $SFXPlayer

var current_slide = 0


func _ready():
	select_slide(current_slide)


func select_slide(num: int):
	for i in rule_container.get_child_count():
		var child = rule_container.get_child(i)
		if i == num:
			child.show()
		else:
			child.hide()


func _on_arrow_left_pressed():
	current_slide = current_slide - 1
	if current_slide < 0:
		current_slide = rule_container.get_child_count() + current_slide
	select_slide(current_slide)
	sfx_player.play()


func _on_arrow_right_pressed():
	current_slide = (current_slide + 1) % rule_container.get_child_count()
	select_slide(current_slide)
	sfx_player.play()
