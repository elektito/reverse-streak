extends Area2D

signal collected()
signal lost()

var ship
var collected := false

onready var size = Vector2(16, 16)

func _on_Collectible_area_entered(area):
	collected = true
	emit_signal("collected")
	queue_free()


func _on_visibility_notifier_screen_exited():
	if not collected:
		emit_signal("lost")
	queue_free()
