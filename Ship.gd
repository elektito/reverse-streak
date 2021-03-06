extends Area2D

signal death_started()
signal died()

export (Vector2) var game_screen_size := Vector2(ProjectSettings.get('display/window/size/width'), ProjectSettings.get('display/window/size/height'))

var size := Vector2.ZERO setget set_size, get_size
var has_died := false

onready var sprite: Sprite = $sprite
onready var shape: CollisionPolygon2D = $shape
var sprite_left: Sprite
var sprite_right: Sprite
var shape_left: CollisionPolygon2D
var shape_right: CollisionPolygon2D


func _ready():
	# add extra sprites/shapes to the left and right to create an illusion of
	# wrap-around
	sprite_left = sprite.duplicate()
	sprite_left.position.x = -game_screen_size.x
	add_child(sprite_left)
	
	shape_left = shape.duplicate()
	shape_left.position.x = -game_screen_size.x
	add_child(shape_left)
	
	sprite_right = sprite.duplicate()
	sprite_right.position.x = game_screen_size.x
	add_child(sprite_right)
	
	shape_right = shape.duplicate()
	shape_right.position.x = game_screen_size.x
	add_child(shape_right)


func _process(delta):
	if position.x < -size.x / 2:
		position.x += game_screen_size.x
	if position.x > game_screen_size.x + size.x / 2:
		position.x -= game_screen_size.x


func set_size(value: Vector2):
	# property can't be set
	pass


func get_size() -> Vector2:
	return sprite.texture.get_size()


func _on_Ship_area_entered(area):
	if not has_died:
		die()


func die():
	has_died = true
	emit_signal("death_started")
	$explosion_sound.play()
	$sprite.visible = false
	sprite_left.visible = false
	sprite_right.visible = false
	$explosion_disc.visible = true
	$shape.set_deferred("disabled", true)
	$trail_particles.visible = false
	$explosion_particles.emitting = true
	yield(get_tree().create_timer(0.02), "timeout")
	$explosion_disc.visible = false
	yield(get_tree().create_timer(0.02), "timeout")
	$explosion_disc.visible = true
	yield(get_tree().create_timer(0.02), "timeout")
	$explosion_disc.visible = false
	yield(get_tree().create_timer($explosion_particles.lifetime * 4), "timeout")
	emit_signal("died")


func indicate_reverse():
	var duration := 0.5
	var prev_y = $reverse_flier.position.y
	var prev_scale = $reverse_flier.scale
	$reverse_flier.visible = true
	$reverse_tween.interpolate_property($reverse_flier, "position:y", null, $reverse_flier.position.y - 10.0, duration, Tween.TRANS_SINE, Tween.EASE_IN)
	$reverse_tween.interpolate_property($reverse_flier, "scale", null, $reverse_flier.scale * 6.0, duration, Tween.TRANS_SINE, Tween.EASE_IN)
	$reverse_tween.interpolate_property($reverse_flier, "modulate:a", null, 0.0, duration, Tween.TRANS_SINE, Tween.EASE_IN)
	$reverse_tween.start()
	yield($reverse_tween, "tween_all_completed")
	$reverse_flier.position.y = prev_y
	$reverse_flier.modulate.a = 1.0
	$reverse_flier.scale = prev_scale
	$reverse_flier.visible = false
