extends Node2D

const HIGHSCORES_FILE := 'user://highscores.json'
const N_HIGHSCORES := 8

var highscores := []

onready var music = $music


func _ready():
	load_highscores()


func read_json_file(filename):
	var file = File.new()
	if not file.file_exists(filename):
		return null
	file.open(filename, File.READ)
	return parse_json(file.get_line())


func write_json_file(filename, value):
	var file = File.new()
	file.open(filename, File.WRITE)
	file.store_line(to_json(value))


func load_highscores():
	var value = read_json_file(HIGHSCORES_FILE)
	if value != null:
		highscores = value


func add_highscore(score):
	var record = {
		'score': score,
	}
	if len(highscores) < N_HIGHSCORES:
		highscores.append(record)
		highscores.sort_custom(self, "_highscore_cmp_func")
		write_json_file(HIGHSCORES_FILE, highscores)
		return true
	var lowest_highscore = highscores[-1]['score'] if len(highscores) > 0 else 0
	if score < lowest_highscore:
		return false
	highscores.append(record)
	highscores.sort_custom(self, "_highscore_cmp_func")
	highscores = highscores.slice(0, N_HIGHSCORES)
	write_json_file(HIGHSCORES_FILE, highscores)
	return true


func _highscore_cmp_func(a, b):
	return a['score'] > b['score']
