extends Area2D

signal killed(enemy)

func _on_Enemy_area_entered(area):
	if area.is_in_group("bullets"):
		emit_signal("killed", self)
	
	queue_free()
