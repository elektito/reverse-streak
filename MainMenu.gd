extends Control

var master_bus = AudioServer.get_bus_index('Master')
var sfx_bus = AudioServer.get_bus_index('SFX')
var music_bus = AudioServer.get_bus_index('Music')

func _ready():
	var menu_screen = preload("res://MenuScreen.tscn").instance()
	menu_screen.menu = [
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
			'name': 'exit',
			'type': 'button',
			'title': 'Exit',
		},
	]
	add_child(menu_screen)
	menu_screen.connect("button_clicked", self, "_on_menu_button_pressed")
	menu_screen.connect("slider_value_changed", self, "_on_menu_slider_value_changed")


func _on_menu_button_pressed(name: String):
	match name:
		'new_game':
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
