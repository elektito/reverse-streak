extends Area2D

export(Vector2) var direction := Vector2.UP
export(float) var speed:= 600.0

func _physics_process(delta):
	position += direction.rotated(rotation) * speed * delta


func _on_Bullet_area_entered(area):
	queue_free()


func _on_visibility_notifier_screen_exited():
	queue_free()
