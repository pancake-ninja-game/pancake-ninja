class_name Scoreboard
extends Control

@onready var label: Label = $Label


func update_label(yield_: int, ppm: int) -> void:
	label.text = "Yield: %d%%\nPPM: %d" % [yield_, ppm]

	
func _on_score_changed(yield_: int, ppm: int) -> void:
	update_label(yield_, ppm)
