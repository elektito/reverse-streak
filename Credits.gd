extends Control

var menu_screen
onready var first_focus = $back_btn

func _on_back_btn_pressed():
	menu_screen.go_to_parent_menu()
