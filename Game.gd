extends Control

const HORIZONTAL_SPEED := 240.0
const VERTICAL_SPEED := 350.0

var mothership_spawn_rate = 0.1

var score := 0
var multiplier := 1
var reversed := false

onready var camera = $camera
onready var ship = $camera/ship
onready var score_label = $hud/score_label
onready var shoot_sound = $shoot_sound

onready var ship_size: Vector2 = ship.sprite.texture.get_size()

func _ready():
	ship.position.x = rect_size.x / 2 - ship.size.x / 2
	ship.position.y = rect_size.y - 80
	
	# fire the timer once at the time it takes to scroll one row (plus some)
	var row_height = ship_size.y
	var pixel_scroll_time = 1.0 / VERTICAL_SPEED
	var row_scroll_time = row_height * pixel_scroll_time
	row_scroll_time = (row_height + 5) / VERTICAL_SPEED
	$enemy_spawn_timer.start(row_scroll_time)


func _physics_process(delta):
	camera.position.y -= VERTICAL_SPEED * delta
	if ship.has_died:
		return
	
	var dir = Vector2.ZERO
	if Input.is_action_pressed("left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("right"):
		dir = Vector2.RIGHT
	
	if reversed:
		dir = -dir
	
	ship.position += dir * HORIZONTAL_SPEED * delta
	
	if Input.is_action_just_pressed("shoot"):
		var bullet = preload("res://Bullet.tscn").instance()
		bullet.position.x = ship.position.x
		bullet.position.y = ship.position.y - 2
		bullet.direction = Vector2.UP
		camera.add_child(bullet)
		shoot_sound.play()


func _on_enemy_spawn_timer_timeout():
	var enemy_spawn_rate := 0.0
	var nenemies = len(get_tree().get_nodes_in_group('enemies'))
	enemy_spawn_rate = 1.0 / (nenemies + 4)
	if randf() > enemy_spawn_rate:
		return
	var enemy = preload("res://Enemy.tscn").instance()
	var columns = int(floor((rect_size.x - 2 * ship_size.x) / ship_size.x))
	var column = randi() % columns
	enemy.position.x = ship_size.x + column * ship_size.x
	enemy.position.y = camera.position.y - enemy.get_node('sprite').texture.get_size().y
	enemy.ship = ship
	enemy.type = 1 if randf() < mothership_spawn_rate else 0
	enemy.connect("killed", self, "_on_enemy_killed")
	add_child(enemy)


func _on_enemy_killed(enemy):
	score += 1 * multiplier
	if enemy.type == 1:
		multiplier *= 2
		reverse_controls()


func _on_ship_death_started():
	$camera/screen_shake.start(0.35, 60, 5)


func _process(delta):
	score_label.text = str(score)


func reverse_controls():
	reversed = not reversed
	if reversed:
		$ParallaxBackground/ParallaxLayer/Sprite.modulate = Color.red
	else:
		$ParallaxBackground/ParallaxLayer/Sprite.modulate = Color.white
