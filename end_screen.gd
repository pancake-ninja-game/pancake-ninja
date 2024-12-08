extends CanvasLayer

@onready var final_score: Label = $FinalScore


func update_final_score(yield_: int, ppm: int) -> void:
	final_score.text = "Final Score:\nYield: %d%%\nPPM: %d" % [yield_, ppm]


func _on_score_changed(yield_: int, ppm: int) -> void:
	update_final_score(yield_, ppm)
