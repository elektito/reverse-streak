extends CenterContainer

onready var first_focus = $vbox/back/margin/btn


func _ready():
	if Global.highscores:
		$vbox/scores.get_child(0).queue_free()
		for highscore in Global.highscores:
			add_highscore_label(highscore['score'])


func add_highscore_label(score):
	var label = Label.new()
	label.text = str(score)
	label.align = Label.ALIGN_CENTER
	label.theme = preload("res://Theme.tres")
	$vbox/scores.add_child(label)


func _on_back_btn_pressed():
	var menu_screen = get_meta('menu_screen')
	menu_screen.go_to_parent_menu()
