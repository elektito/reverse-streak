extends Area2D

signal killed(enemy)

var ship

var keep_y = false

func _on_Enemy_area_entered(area):
	if area.is_in_group("bullets"):
		emit_signal("killed", self)
	
	die()


func _physics_process(delta):
	if ship and global_position.y >= ship.global_position.y and not keep_y:
		$death_timer.start()
		keep_y = true
	
	if keep_y and ship:
		global_position.y = ship.global_position.y
	
	print(global_position.y, ' ', ship.global_position.y)


func _on_death_timer_timeout():
	die()


func die():
	queue_free()
