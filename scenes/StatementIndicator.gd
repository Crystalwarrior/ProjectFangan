extends HBoxContainer

var hollow_tex = preload("res://ui/hollowcircle.png")
var full_tex = preload("res://ui/fullcircle.png")

func set_statements(number: int):
	for child in get_children():
		child.queue_free()
	for i in range(number):
		var indicator := TextureRect.new()
		indicator.ignore_texture_size = true
		indicator.set_custom_minimum_size(Vector2i(32, 32))
		indicator.texture = hollow_tex
		indicator.name = str(i+1)
		self.add_child(indicator)

func select_statement(idx: int):
	for child in get_children():
		child.texture = hollow_tex
		if child.name == str(idx):
			child.texture = full_tex
