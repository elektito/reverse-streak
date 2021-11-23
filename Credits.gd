extends Control

onready var first_focus = $back_btn

func _on_back_btn_pressed():
	var menu_screen = get_meta('menu_screen')
	menu_screen.go_to_parent_menu()
