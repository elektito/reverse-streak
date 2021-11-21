extends Control

signal button_clicked(name)
signal slider_value_changed(name, value)

var transition_time := 0.3

var menu = [
	{
		'name': 'new_game',
		'type': 'button',
		'title': 'New Game',
	},
	{
		'name': 'settings',
		'type': 'submenu',
		'title': 'Settings',
		'menu': [
			{
				'name': 'master_volume',
				'type': 'slider',
				'title': 'Master',
			},
			{
				'name': 'sfx_volume',
				'type': 'slider',
				'title': 'SFX',
			},
			{
				'name': 'music_volume',
				'type': 'slider',
				'title': 'Music',
			},
			{
				'name': 'settings_back',
				'type': 'back',
				'title': 'Back',
			}
		]
	},
	{
		'name': 'exit',
		'type': 'button',
		'title': 'Exit',
	},
]

var items := []
var current_menu: Control

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		go_to_parent_menu()


func _ready():
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
	menu_container.rect_position.x = rect_size.x
	btn.set_meta('menu_container', menu_container)
	menu_container.set_meta('parent_menu', parent)
	
	return btn


func add_back(desc, parent: Control) -> Button:
	var  btn := Button.new()
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
	slider.size_flags_horizontal = SIZE_EXPAND_FILL
	slider.rect_min_size.x = 100
	slider.ticks_on_borders = true
	slider.connect("value_changed", self, "_on_slider_changed", [desc, slider])
	slider.connect("focus_entered", self, "_on_slider_focus_entered", [slider, label])
	slider.connect("focus_exited", self, "_on_slider_focus_exited", [slider, label])
	hbox.add_child(slider)
	
	parent.get_node('vbox').add_child(hbox)
	
	return slider


func _on_button_clicked(desc: Dictionary, btn: Button):
	if desc['type'] == 'submenu':
		var submenu = btn.get_meta('menu_container')
		var scrw = ProjectSettings.get('display/window/size/width')
		$transition_tween.interpolate_property(current_menu, "rect_position:x", current_menu.rect_position.x, current_menu.rect_position.x - scrw, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$transition_tween.interpolate_property(submenu, "rect_position:x", submenu.rect_position.x, submenu.rect_position.x - scrw, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$transition_tween.start()
		yield($transition_tween, "tween_all_completed")
		current_menu.set_meta('last_focus', get_focus_owner())
		current_menu = submenu
		current_menu.get_meta('first').grab_focus()
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
	var parent_menu = current_menu.get_meta('parent_menu')
	if parent_menu == null:
		return
	var scrw = ProjectSettings.get('display/window/size/width')
	$transition_tween.interpolate_property(current_menu, "rect_position:x", current_menu.rect_position.x, current_menu.rect_position.x + scrw, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$transition_tween.interpolate_property(parent_menu, "rect_position:x", parent_menu.rect_position.x, parent_menu.rect_position.x + scrw, transition_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$transition_tween.start()
	yield($transition_tween, "tween_all_completed")
	current_menu = parent_menu
	var last_focus = current_menu.get_meta('last_focus')
	if last_focus:
		last_focus.grab_focus()
	else:
		current_menu.get_meta('first').grab_focus()
