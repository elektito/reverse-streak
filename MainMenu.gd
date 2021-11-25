extends PanelContainer

signal resume()

export(bool) var pause_screen := false

var master_bus = AudioServer.get_bus_index('Master')
var sfx_bus = AudioServer.get_bus_index('SFX')
var music_bus = AudioServer.get_bus_index('Music')

var menu_screen

func _ready():
	menu_screen = preload("res://MenuScreen.tscn").instance()
	menu_screen.menu = get_menu()
	add_child(menu_screen)
	menu_screen.connect("button_clicked", self, "_on_menu_button_pressed")
	menu_screen.connect("slider_value_changed", self, "_on_menu_slider_value_changed")


func init():
	menu_screen.menu = get_menu()
	menu_screen.init_menu()


func get_menu():
	return [
		{
			'name': 'resume_game',
			'type': 'button',
			'title': 'Resume Game',
			'visible': pause_screen,
		},
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
					'value': db2linear(AudioServer.get_bus_volume_db(master_bus)),
				},
				{
					'name': 'sfx_volume',
					'type': 'slider',
					'title': 'SFX',
					'value': db2linear(AudioServer.get_bus_volume_db(sfx_bus)),
				},
				{
					'name': 'music_volume',
					'type': 'slider',
					'title': 'Music',
					'value': db2linear(AudioServer.get_bus_volume_db(music_bus)),
				},
				{
					'name': 'settings_back',
					'type': 'back',
					'title': 'Back',
				}
			]
		},
		{
			'name': 'highscores',
			'type': 'scene',
			'title': 'High Scores',
			'scene': 'res://Highscores.tscn',
		},
		{
			'name': 'credits',
			'type': 'scene',
			'title': 'Credits',
			'scene': 'res://Credits.tscn',
		},
		{
			'name': 'exit',
			'type': 'button',
			'title': 'Exit',
		},
	]


func _unhandled_input(event):
	if pause_screen and Input.is_action_just_pressed("ui_cancel"):
		emit_signal("resume")
		get_tree().set_input_as_handled()


func _on_menu_button_pressed(name: String):
	match name:
		'resume_game':
			emit_signal("resume")
		'new_game':
			get_tree().paused = false
			Global.music.play()
			get_tree().change_scene("res://Game.tscn")
		'exit':
			get_tree().quit()


func _on_menu_slider_value_changed(name: String, value: float):
	match name:
		'master_volume':
			AudioServer.set_bus_volume_db(master_bus, linear2db(value))
		'sfx_volume':
			AudioServer.set_bus_volume_db(sfx_bus, linear2db(value))
		'music_volume':
			AudioServer.set_bus_volume_db(music_bus, linear2db(value))
