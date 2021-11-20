extends Area2D

signal killed(enemy)

enum EnemyType { NORMAL_ENEMY, MOTHERSHIP }

export(EnemyType) var type = EnemyType.NORMAL_ENEMY setget set_type, get_type

var size := Vector2(32, 32)

var ship
var keep_y = false
var column

onready var sprite = $sprite


func _ready():
	set_type(type)


func _on_Enemy_area_entered(area):
	if area.is_in_group("bullets"):
		emit_signal("killed", self)
	
	die()


func _physics_process(delta):
	if ship and not ship.has_died and global_position.y >= ship.global_position.y and not keep_y:
		$death_timer.start()
		keep_y = true
	elif ship.has_died and global_position.y >= ship.get_parent().get_parent().rect_size.y + size.y:
		die()
	
	if keep_y and ship:
		global_position.y = ship.global_position.y


func _on_death_timer_timeout():
	die()


func die():
	$death_sound.play()
	visible = false
	$shape.set_deferred("disabled", false)
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	yield($death_sound, "finished")
	queue_free()


func set_type(value: int):
	type = value
	if sprite == null:
		return
	var animations := {
		EnemyType.NORMAL_ENEMY: 'enemy1',
		EnemyType.MOTHERSHIP: 'mothership',
	}
	sprite.animation = animations[type]


func get_type() -> int:
	return type
