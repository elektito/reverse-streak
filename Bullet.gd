extends Area2D

export(Vector2) var direction := Vector2.UP
export(float) var speed:= 600.0

func _physics_process(delta):
	position += direction * speed * delta
	
	if position.y < -$sprite.texture.get_size().y / 2:
		queue_free()


func _on_Bullet_area_entered(area):
	queue_free()
