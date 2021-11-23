extends Control

signal button_clicked(name)
signal slider_value_changed(name, value)

enum TransitionDirection { LEFT, RIGHT }

var transition_time := 0.3
var scrw = ProjectSettings.get('display/window/size/width')

var menu

var items := []
var current_menu: Control
var menu_disabled := false

func _input(event):
	if menu_disabled:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		if go_to_parent_menu():
			get_tree().set_input_as_handled()


func _ready():
	init_menu()


func init_menu():
	for child in get_children():
		if child != $center and child is Control:
			child.queue_free()
	if menu:
		create_menu(menu, $center)
		current_menu = $center


func create_menu(menu, parent):
	parent.rect_min_size.x = ProjectSettings.get('display/window/size/width')
	parent.rect_min_size.y = ProjectSettings.get('display/window/size/height')
	
	var vbox: VBoxContainer = parent.get_node('vbox')
	for child in vbox.get_children():
		vbox.remove_child(child)
	
	var first: Control = null
	var prev: Control = null
	for desc in menu:
		if not desc.get('visible', true):
			continue
		var factory = 'add_' + desc['type']
		var item: Control = call(factory, desc, parent)
		if prev:
			prev.focus_next = item.get_path()
			prev.focus_neighbour_bottom = item.get_path()
			item.focus_previous = prev.get_path()
			item.focus_neighbour_top = prev.get_path()
		else:
			first = item
		item.focus_neighbour_right = item.get_path()
		item.focus_neighbour_left = item.get_path()
		item.connect("focus_entered", self, '_on_item_focus_entered')
		prev = item
	
	if prev and prev != first:
		var last = prev
		last.focus_next = first.get_path()
		last.focus_neighbour_bottom = first.get_path()
		first.focus_previous = last.get_path()
		first.focus_neighbour_top = last.get_path()
	
	first.grab_focus()
	parent.set_meta('first', first)


func add_button(desc, parent: Control) -> Button:
	var btn := Button.new()
	btn.name = desc['name']
	btn.text = desc['title']
	btn.theme = preload("res://Theme.tres")
	btn.connect("pressed", self, "_on_button_clicked", [desc, btn])
	parent.get_node('vbox').add_child(btn)
	return btn


func add_submenu(desc, parent: Control) -> Button:
	var btn := Button.new()
	btn.name = desc['name']
	btn.text = desc['title']
	btn.theme = preload("res://Theme.tres")
	btn.connect("pressed", self, "_on_button_clicked", [desc, btn])
	parent.get_node('vbox').add_child(btn)
	
	var menu_container: CenterContainer = parent.duplicate()
	add_child(menu_container)
	create_menu(desc['menu'], menu_container)
	menu_container.rect_position.x = rect_position.x + rect_size.x
	btn.set_meta('menu_container', menu_container)
	menu_container.set_meta('parent_menu', parent)
	
	return btn


func add_back(desc, parent: Control) -> Button:
	var btn := Button.new()
	btn.name = desc['name']
	btn.text = desc['title']
	btn.theme = preload("res://Theme.tres")
	btn.connect("pressed", self, "_on_button_clicked", [desc, btn])
	parent.get_node('vbox').add_child(btn)
	return btn


func add_slider(desc, parent: Control) -> HSlider:
	var hbox := HBoxContainer.new()
	
	var theme = preload("res://Theme.tres")
	var color = theme.get_stylebox("grabber_area", "HSlider").bg_color
	color.a = 1.0
	
	var label := Label.new()
	label.text = desc['title'] + ':'
	label.theme = preload("res://Theme.tres")
	label.add_color_override("font_color", color)
	hbox.add_child(label)
	
	var slider := HSlider.new()
	slider.name = desc['name']
	slider.theme = preload("res://Theme.tres")
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.tick_count = 10
	slider.value = desc.get('value', 0.0)
	slider.size_flags_horizontal = SIZE_EXPAND_FILL
	slider.rect_min_size.x = 100
	slider.ticks_on_borders = true
	slider.connect("value_changed", self, "_on_slider_changed", [desc, slider])
	slider.connect("focus_entered", self, "_on_slider_focus_entered", [slider, label])
	slider.connect("focus_exited", self, "_on_slider_focus_exited", [slider, label])
	hbox.add_child(slider)
	
	parent.get_node('vbox').add_child(hbox)
	
	return slider


func add_scene(desc: Dictionary, parent: Control) -> Button:
	var btn := Button.new()
	btn.name = desc['name']
	btn.text = desc['title']
	btn.theme = preload("res://Theme.tres")
	btn.connect("pressed", self, "_on_button_clicked", [desc, btn])
	parent.get_node('vbox').add_child(btn)
	
	var scene = load(desc['scene']).instance()
	add_child(scene)
	scene.menu_screen = self
	scene.rect_position.x = rect_position.x + rect_size.x
	btn.set_meta('subscene', scene)
	scene.set_meta('parent_menu', parent)
	
	return btn


func _on_button_clicked(desc: Dictionary, btn: Button):
	if menu_disabled:
		return
	if desc['type'] == 'submenu':
		var submenu = btn.get_meta('menu_container')
		transition(TransitionDirection.RIGHT, submenu)
		current_menu.set_meta('last_focus', get_focus_owner())
		current_menu = submenu
		current_menu.get_meta('first').grab_focus()
	elif desc['type'] == 'scene':
		var subscene = btn.get_meta('subscene')
		transition(TransitionDirection.RIGHT, subscene)
		current_menu.set_meta('last_focus', get_focus_owner())
		current_menu = subscene
		if subscene.first_focus:
			subscene.first_focus.grab_focus()
	elif desc['type'] == 'back':
		go_to_parent_menu()
	else:
		emit_signal("button_clicked", desc['name'])


func _on_slider_changed(value: float, desc: Dictionary, slider: HSlider):
	emit_signal("slider_value_changed", desc['name'], value)


func _on_slider_focus_entered(slider: HSlider, label: Label):
	var color = slider.theme.get_stylebox("grabber_area_highlight", "HSlider").bg_color
	color.a = 1.0
	label.add_color_override("font_color", color)


func _on_slider_focus_exited(slider: HSlider, label: Label):
	var color = slider.theme.get_stylebox("grabber_area", "HSlider").bg_color
	color.a = 1.0
	label.add_color_override("font_color", color)


func go_to_parent_menu():
	if menu_disabled:
		return
	var parent_menu = current_menu.get_meta('parent_menu')
	if parent_menu == null:
		return false
	var last_focus = parent_menu.get_meta('last_focus')
	if last_focus:
		last_focus.grab_focus()
	else:
		parent_menu.get_meta('first').grab_focus()
	transition(TransitionDirection.LEFT, parent_menu)
	current_menu = parent_menu
	return true


func transition(direction: int, other_menu):
	var current_menu_target_x: float
	var other_menu_target_x: float
	if direction == TransitionDirection.LEFT:
		current_menu_target_x = current_menu.rect_position.x + scrw
		other_menu_target_x = other_menu.rect_position.x + scrw
	else:
		current_menu_target_x = current_menu.rect_position.x - scrw
		other_menu_target_x = other_menu.rect_position.x - scrw
	menu_disabled = true
	$transition_tween.interpolate_property(current_menu, "rect_position:x", null, current_menu_target_x, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$transition_tween.interpolate_property(other_menu, "rect_position:x", null, other_menu_target_x, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$transition_tween.start()
	yield($transition_tween, "tween_all_completed")
	menu_disabled = false


func _on_item_focus_entered():
	$select_sound.play()
