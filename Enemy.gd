extends Area2D

signal killed(enemy)

enum EnemyType { NORMAL_ENEMY, MOTHERSHIP }

export(EnemyType) var type = EnemyType.NORMAL_ENEMY setget set_type, get_type

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


func _on_death_timer_timeout():
	die()


func die():
	queue_free()


func set_type(value: int):
	type = value
	var sprites := {
		EnemyType.NORMAL_ENEMY: preload("res://assets/enemy1.png"),
		EnemyType.MOTHERSHIP: preload("res://assets/enemy2.png"),
	}
	$sprite.texture = sprites[type]


func get_type() -> int:
	return type
