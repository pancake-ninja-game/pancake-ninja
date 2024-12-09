class_name StackScene
extends Node2D

signal stack_completed

const CAPACITY: int = 5
const SHEET_SPACING: int = 5
	
var sheets: Array[SheetScene] = []

@onready var sheet_stacked_sound: AudioStreamPlayer2D = $SheetStackedSound
@onready var stack_completed_sound: AudioStreamPlayer2D = $StackCompletedSound


func is_full() -> bool:
	return len(sheets) >= CAPACITY


func stack_sheet(sheet: SheetScene) -> void:
	if is_full():
		empty()
		stack_completed_sound.play()
		stack_completed.emit()
	else:
		sheet_stacked_sound.play()
		
	sheets.append(sheet)
	sheet.reparent(self)
	
	sheet.move_to_stack(Vector2(
		0,
		0 - SHEET_SPACING * len(sheets),
	))


func empty() -> void:
	for s: SheetScene in sheets:
		s.queue_free()
	sheets.clear()


func _on_main_game_started() -> void:
	empty()
