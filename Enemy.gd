extends Area2D



func _on_Enemy_area_entered(area):
	queue_free()
