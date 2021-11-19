extends Node

# code from: https://youtu.be/_DAvzzJMko8

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var camera = get_parent()

func start(duration=0.2, frequency=15, amplitude=3, priority=0):
	if priority >= self.priority:
		self.amplitude = amplitude

		$duration_timer.wait_time = duration
		$frequency_timer.wait_time = 1.0 / float(frequency)
		$frequency_timer.start()
		$duration_timer.start()
		
		_new_shake()

func _new_shake():
	var rand = Vector2.ZERO
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)

	$tween.interpolate_property(camera, 'offset', camera.offset, rand, $frequency_timer.wait_time, TRANS, EASE)
	$tween.start()

func _reset():
	$tween.interpolate_property(camera, 'offset', camera.offset, Vector2.ZERO, $frequency_timer.wait_time, TRANS, EASE)
	$tween.start()

	priority = 0

func _on_duration_timer_timeout():
	_reset()
	$frequency_timer.stop()

func _on_frequency_timer_timeout():
	_new_shake()
