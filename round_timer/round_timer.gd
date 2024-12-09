class_name RoundTimerScene
extends Node2D

signal timeout
signal tick(time_passed: int)
signal level_change_requested(level_index: int)

var time_left: int

@onready var timer: Timer = $Timer
@onready var label: Label = $Label


func _ready() -> void:
	reset()


func reset() -> void:
	time_left = globals.ROUND_LENGTH
	update_label()


func start() -> void:
	timer.start()


func stop() -> void:
	timer.stop()


func update_label() -> void:
	label.text = str(time_left)


func emit_tick() -> void:
	var t: int = globals.ROUND_LENGTH - time_left
	tick.emit(t)


func _on_timer_timeout() -> void:
	time_left -= 1
	update_label()
	emit_tick()
	
	if time_left == 0:
		timeout.emit()
		timer.stop()
		return
		
	if time_left % (globals.ROUND_LENGTH / globals.LEVELS) == 0:
		var next: int = (globals.ROUND_LENGTH - time_left) / (globals.ROUND_LENGTH / globals.LEVELS)
		level_change_requested.emit(next)


func _on_main_game_started() -> void:
	reset()
	start()


func _on_main_game_ended() -> void:
	stop()
