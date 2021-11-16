extends Control

const HORIZONTAL_SPEED := 240.0
const VERTICAL_SPEED := 380.0

var score := 0
var multiplier := 1
var reversed := false

onready var camera = $camera
onready var ship = $camera/ship
onready var score_label = $hud/score_label

func _ready():
	ship.position.x = rect_size.x / 2 - ship.size.x / 2
	ship.position.y = rect_size.y - 80


func _physics_process(delta):
	var dir = Vector2.ZERO
	if Input.is_action_pressed("left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("right"):
		dir = Vector2.RIGHT
	
	if reversed:
		dir = -dir
	
	ship.position += dir * HORIZONTAL_SPEED * delta
	camera.position.y -= VERTICAL_SPEED * delta
	
	if Input.is_action_just_pressed("shoot"):
		var bullet = preload("res://Bullet.tscn").instance()
		bullet.position.x = ship.position.x
		bullet.position.y = ship.position.y - 2
		bullet.direction = Vector2.UP
		camera.add_child(bullet)


func _on_enemy_spawn_timer_timeout():
	var enemy = preload("res://Enemy.tscn").instance()
	enemy.position.x = rand_range(32, rect_size.x - 32)
	enemy.position.y = $camera.position.y - 100
	enemy.ship = ship
	enemy.type = 1 if randf() < 0.1 else 0
	enemy.connect("killed", self, "_on_enemy_killed")
	add_child(enemy)


func _on_enemy_killed(enemy):
	score += 1 * multiplier
	if enemy.type == 1:
		multiplier *= 2
		reverse_controls()


func _process(delta):
	score_label.text = str(score)


func reverse_controls():
	reversed = not reversed
	if reversed:
		$ParallaxBackground/ParallaxLayer/Sprite.modulate = Color.red
	else:
		$ParallaxBackground/ParallaxLayer/Sprite.modulate = Color.white
