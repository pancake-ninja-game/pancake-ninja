extends Node2D

var game_duration = 45
var game_active = false
var round_timer = 0

@export var sheet_scene: PackedScene
@export var screen_width: float = 1280
@export var screen_height: float = 720

var pancake_y_pos = 400

var sheet_spacing: float = 0
var sheet_speed: float = 200
var stack_capacity = 5

var pancake = []
var stacked_sheets = []
var scrapped_sheets = []

var ok_timestamps = []
var ng_timestamps = []

var sample_seconds = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Dynamically calculate sheet spacing
	var tmp_sheet = sheet_scene.instantiate()
	add_child(tmp_sheet)
	sheet_spacing = tmp_sheet.sheet_width - 1
	sheet_speed = tmp_sheet.move_speed
	tmp_sheet.queue_free()
	
	# Set the timer interval
	var spawn_interval = sheet_spacing / sheet_speed
	$GameLayer/SheetSpawnTimer.wait_time = spawn_interval
	
	show_start_screen()

func stop_all_music():
	$StartScreenMusic.stop()
	$EndScreenMusic.stop()
	$GameMusic.stop()
	
func show_start_screen():
	stop_all_music()
	$StartScreenMusic.play()
	
	$StartScreen.visible = true
	$EndScreen.visible = false
	$GameLayer.visible = true
	$GameLayer/CanvasLayer.visible = false
	$GameLayer/Operator.visible = false
	
func start_game():
	stop_all_music()
	$GameMusic.play()
	
	$StartScreen.visible = false
	$EndScreen.visible = false
	$GameLayer/CanvasLayer.visible = true
	$GameLayer/Operator.visible = true
	game_active = true
	round_timer = game_duration
	$GameLayer/RoundTimerLabel.text = str(game_duration)
	$GameLayer/SheetSpawnTimer.start()
	$GameLayer/RoundTimer.start()

func end_game():
	stop_all_music()
	$EndScreenMusic.play()
	
	print("game ended")
	for s in pancake:
		s.visible = false
		
	show_end_screen()
	
func show_end_screen():
	$GameLayer/CanvasLayer.visible = false
	$GameLayer/Operator.visible = false
	$EndScreen.visible = true
	$EndScreen/FinalScoreLabel.text = "Final Score:\nYield: %d%%\nPPM: %d" % [calculate_yield(), calculate_ppm()]
	game_active = false

func restart_game():
	reset_game_state()
	start_game()
	
func reset_game_state():
	ok_timestamps.clear()
	ng_timestamps.clear()
	round_timer = game_duration
	$GameLayer/RoundTimer.stop()
	$GameLayer/SheetSpawnTimer.stop()
	
	for sheet in pancake + scrapped_sheets + stacked_sheets:
		sheet.queue_free()
	pancake.clear()
	scrapped_sheets.clear()
	stacked_sheets.clear()

func _on_Round_Timer_timeout():
	round_timer -= 1
	$GameLayer/RoundTimerLabel.text = str(round_timer)
	
	if round_timer <= 0:
		$GameLayer/RoundTimer.stop()
		$GameLayer/SheetSpawnTimer.stop()
		end_game()
	

func set_score(yield_, ppm):
	pass
	
func _on_SheetSpawnTimer_timeout():
	spawn_sheet()
	
func spawn_sheet():
	var s = sheet_scene.instantiate()
	s.position = Vector2(-sheet_spacing, pancake_y_pos)
	s.connect("ok_cut_detected", Callable(self, "_on_ok_cut_detected"))
	s.connect("ng_cut_detected", Callable(self, "_on_ng_cut_detected"))
	add_child(s)
	pancake.append(s)

func stack_sheet(s):
	if stacked_sheets.size() == stack_capacity:
		$FlushStackSound.play()
		flush_stacked_sheets()
		
	pancake.erase(s)
	stacked_sheets.append(s)
	s.stack_in_jr()
	
	ok_timestamps.append(Time.get_ticks_msec())
	
func scrap_sheets_until(s):
	var idx = pancake.find(s) + 1
	
	for sheet in pancake.slice(0, idx):
		sheet.scrap()
		ng_timestamps.append(Time.get_ticks_msec())
	
	scrapped_sheets.append_array(pancake.slice(0, idx))
	pancake = pancake.slice(idx)
	
func flush_stacked_sheets():
	for sheet in stacked_sheets:
		sheet.queue_free()
		
	stacked_sheets.clear()
	
	# Reset stack height
	# Any better way to do this?
	if sheet_scene:
		var tmp_sheet = sheet_scene.instantiate()
		tmp_sheet.reset_jr_height()
		tmp_sheet.queue_free()
	
func _on_ok_cut_detected(triggered_sheet):
	$GameLayer/Operator.play_cutting_animation()
	
	if pancake[0] == triggered_sheet:
		stack_sheet(pancake[0])
		return
	
	scrap_sheets_until(triggered_sheet)

func _on_ng_cut_detected(triggered_sheet):
	$GameLayer/Operator.play_cutting_animation()
	scrap_sheets_until(triggered_sheet)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Handle resetting sheets when reaching the right screen boundary
func _process(delta: float) -> void:
	if not game_active:
		return
		
	update_scores()
	
	# Make it possible to cut when no sheet is nearby
	# This probably initiates a _lot_ of cutting animation
	# requests. Let's see how performance is affected.
	var mouse_pos = get_global_mouse_position()
	if abs(mouse_pos.y - pancake_y_pos) <= 30:
		$GameLayer/Operator.play_cutting_animation()
	
	
	# Remove sheets that move off-screen to the right
	for sheet in pancake:
		if sheet.position.x > screen_width + sheet_spacing:
			pancake.erase(sheet)
			sheet.queue_free()
			ng_timestamps.append(Time.get_ticks_msec()) # You missed the opportunity - NG material
			
	
	for sheet in scrapped_sheets:
		if sheet.position.y > screen_height + sheet_spacing:
			scrapped_sheets.erase(sheet)
			sheet.queue_free()

func remove_sheet(s):
	pancake.erase(s)
	s.queue_free()

func calculate_yield():
	var yield_pct = 0.0
	
	var ok_count = len(ok_timestamps)
	var ng_count = len(ng_timestamps)
	if ok_count + ng_count > 0:
		yield_pct = float(ok_count) / (ok_count + ng_count) * 100
	
	return yield_pct

func calculate_ppm():
	var ok_count = len(ok_timestamps)
	return ok_count * 60 / sample_seconds / stack_capacity
		
func update_scores():
	var current_time = Time.get_ticks_msec()
	
	ok_timestamps = ok_timestamps.filter(func(timestamp): return current_time - timestamp <= sample_seconds * 1000)
	ng_timestamps = ng_timestamps.filter(func(timestamp): return current_time - timestamp <= sample_seconds * 1000)
	
	var yield_pct = calculate_yield()
	var ppm = calculate_ppm()
	
	$GameLayer/CanvasLayer/ScoreLabel.text = "Yield: %d%%\nPPM: %d" % [yield_pct, ppm]
	
# Debug
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Mouse clicked at: ", event.position)


func _on_start_button_pressed() -> void:
	start_game()


func _on_restart_button_pressed() -> void:
	reset_game_state()
	start_game()
