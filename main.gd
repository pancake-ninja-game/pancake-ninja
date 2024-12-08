extends Node2D

signal line_speed_changed(speed: float)
signal game_started
signal game_ended
signal reset_state_requested

const DEFAULT_LINE_SPEED: int = 200

var is_playing: bool = false
var line_speed: float
var pancake_sheets: Array[SheetScene] = []

var sheet_scene: PackedScene = preload("res://sheet/sheet.tscn")
var stack_scene: PackedScene = preload("res://stack/stack.tscn")

@onready var start_screen: CanvasLayer =$StartScreen
@onready var game_screen: CanvasLayer = $GameScreen
@onready var end_screen: CanvasLayer = $EndScreen

@onready var sheet_spawn_timer: Timer = $GameScreen/SheetSpawnTimer
@onready var round_timer: RoundTimerScene = $GameScreen/RoundTimer
@onready var stack: StackScene = $GameScreen/Stack
@onready var score_manager: ScoreManager = $ScoreManager
@onready var scoreboard: Scoreboard = $GameScreen/Scoreboard

@onready var menu_music: AudioStreamPlayer2D = $MenuMusic
@onready var game_music: AudioStreamPlayer2D = $GameMusic


func _ready() -> void:
	var tmp_sheet: SheetScene = sheet_scene.instantiate()
	add_child(tmp_sheet)
	globals.sheet_width = tmp_sheet.width
	tmp_sheet.queue_free()
	
	set_screen_visibility(true, false, false)
	menu_music.play()

	
func set_line_speed(speed: float) -> void:
	if speed == line_speed:
		return
		
	line_speed = speed
	
	var t: float = globals.sheet_width / line_speed - 0.01
	sheet_spawn_timer.wait_time = t
	line_speed_changed.emit(line_speed)


func set_screen_visibility(start: bool, game: bool, end: bool) -> void:
	start_screen.visible = start
	game_screen.visible = game
	end_screen.visible = end


func remove_uncut_sheets() -> void:
	for s: SheetScene in pancake_sheets:
		s.queue_free()
	pancake_sheets.clear()


func reset_state() -> void:
	is_playing = false
	remove_uncut_sheets()
	reset_state_requested.emit()


func start_game() -> void:
	reset_state()
	
	is_playing = true
	set_screen_visibility(false, true, false)
	set_line_speed(DEFAULT_LINE_SPEED)
	menu_music.stop()
	game_music.play()
	game_started.emit()


func end_game() -> void:
	is_playing = false
	set_screen_visibility(false, false, true)
	remove_uncut_sheets()
	game_music.stop()
	menu_music.play()
	game_ended.emit()


func spawn_sheet() -> void:
	var sheet: SheetScene = sheet_scene.instantiate()
	sheet.position = Vector2(-globals.sheet_width / 2, 400)
	$GameScreen.add_child(sheet)
	
	pancake_sheets.append(sheet)
	
	line_speed_changed.connect(sheet._on_line_speed_changed)
	sheet._on_line_speed_changed(line_speed)
	
	sheet.sheet_cut.connect(self._on_sheet_cut)
	sheet.sheet_cut.connect(score_manager._on_sheet_cut)
	sheet.sheet_missed.connect(self._on_sheet_missed)
	sheet.sheet_missed.connect(score_manager._on_sheet_missed)


func _on_sheet_cut(sheet: SheetScene, ok: bool) -> void:
	if !is_playing:
		return
	
	var sheet_idx: int = pancake_sheets.find(sheet)
	
	if sheet_idx > 0 or !ok:
		for s: SheetScene in pancake_sheets.slice(0, sheet_idx + 1):
			s.drop()
			pancake_sheets.erase(s)
		
		return
	
	pancake_sheets.erase(sheet)
	stack.stack_sheet(sheet)

func _on_sheet_missed(sheet: SheetScene) -> void:
	if !is_playing:
		return
	
	pancake_sheets.erase(sheet)
	sheet.queue_free()


func _on_start_game_pressed() -> void:
	start_game()


func _on_play_again_pressed() -> void:
	start_game()


func _on_sheet_spawn_timer_timeout() -> void:
	if !is_playing:
		return

	spawn_sheet()


func _on_round_timer_timeout() -> void:
	if !is_playing:
		return
	
	end_game()
