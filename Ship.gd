extends Area2D

var size := Vector2.ZERO setget set_size, get_size

onready var sprite = $sprite

func set_size(value: Vector2):
	pass


func get_size() -> Vector2:
	return sprite.texture.get_size()
