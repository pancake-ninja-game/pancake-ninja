class_name Scoreboard
extends Control

@onready var score: Label = $Score
@onready var level: Label = $Level


func update_score(yield_: int, ppm: int) -> void:
	score.text = "Yield: %d%%\nPPM: %d" % [yield_, ppm]


func update_level(level_index: int) -> void:
	level.text = "Level:\n%s" % [globals.LEVEL_NAMES[level_index]]


func _on_score_changed(yield_: int, ppm: int) -> void:
	update_score(yield_, ppm)


func _on_round_timer_level_change_requested(level_index: int) -> void:
	update_level(level_index)


func _on_main_reset_state_requested() -> void:
	update_score(0, 0)
	update_level(0)
