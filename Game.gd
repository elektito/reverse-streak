extends Control

const HORIZONTAL_SPEED := 240.0
const VERTICAL_SPEED := 350.0

var mothership_spawn_rate = 0.1

var score := 0
var multiplier := 1
var reversed := false
var enemies_since_last_mothership := 0

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
	spawn_enemy()


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


func spawn_enemy():
	var enemy = preload("res://Enemy.tscn").instance()
	var ncolumns = int(floor((rect_size.x - 2 * ship_size.x) / ship_size.x))
	var columns = range(ncolumns)
	var vertical_distance = VERTICAL_SPEED * enemy.get_node('death_timer').wait_time
	var unfeasable_columns := []
	for e in get_tree().get_nodes_in_group('enemies'):
		if e.position.y > camera.position.y + vertical_distance:
			continue
		if not e.column in unfeasable_columns:
			unfeasable_columns.append(e.column)
	for c in unfeasable_columns:
		columns.erase(c)
	if len(columns) == 0:
		return
	var column = columns[randi() % len(columns)]
	
	var ship_type
	if enemies_since_last_mothership < 10:
		ship_type = 0
	else:
		ship_type = 1 if randf() < mothership_spawn_rate else 0
	
	if ship_type == 1:
		enemies_since_last_mothership = 0
	else:
		enemies_since_last_mothership += 1
	
	enemy.position.x = ship_size.x + column * ship_size.x
	enemy.position.y = camera.position.y - enemy.size.y
	enemy.ship = ship
	enemy.type = ship_type
	enemy.column = column
	enemy.connect("killed", self, "_on_enemy_killed")
	add_child(enemy)
