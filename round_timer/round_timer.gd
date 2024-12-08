class_name RoundTimerScene
extends Node2D

signal timeout
signal tick(time_passed: int)

const ROUND_LENGTH: int = 15
var time_left: int

@onready var timer: Timer = $Timer
@onready var label: Label = $Label


func _ready() -> void:
	reset()


func reset() -> void:
	time_left = ROUND_LENGTH
	update_label()


func start() -> void:
	timer.start()


func stop() -> void:
	timer.stop()


func update_label() -> void:
	label.text = str(time_left)


func emit_tick() -> void:
	var t: int = ROUND_LENGTH - time_left
	tick.emit(t)


func _on_timer_timeout() -> void:
	time_left -= 1
	update_label()
	emit_tick()
	
	if time_left > 0:
		return
	
	timeout.emit()
	timer.stop()


func _on_main_game_started() -> void:
	reset()
	start()


func _on_main_game_ended() -> void:
	stop()
