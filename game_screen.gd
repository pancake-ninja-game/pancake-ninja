class_name GameScreen
extends CanvasLayer

@onready var sheet_spawn_timer: Timer = $SheetSpawnTimer


func _on_main_game_started() -> void:
	sheet_spawn_timer.start()


func _on_main_game_ended() -> void:
	sheet_spawn_timer.stop()
