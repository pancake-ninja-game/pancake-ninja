extends Node2D

@export var sheet_scene: PackedScene
@export var screen_width: float = 1280
@export var screen_height: float = 720

var pancake_y_pos = 370

var sheet_spacing: float = 0
var sheet_speed: float = 200
var stack_capacity = 6

var pancake = []
var stacked_sheets = []
var scrapped_sheets = []

var ok_cut_timestamps = []
var ng_cut_timestamps = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Dynamically calculate sheet spacing
	var tmp_sheet = sheet_scene.instantiate()
	add_child(tmp_sheet)
	sheet_spacing = tmp_sheet.sheet_width + 10
	sheet_speed = tmp_sheet.move_speed
	tmp_sheet.queue_free()
	
	# Set the timer interval
	var spawn_interval = sheet_spacing / sheet_speed
	$Timer.wait_time = spawn_interval
	$Timer.start()

func set_score(yield_, ppm):
	pass
	
func _on_Timer_timeout():
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
		flush_stacked_sheets()
		
	pancake.erase(s)
	stacked_sheets.append(s)
	s.stack_in_jr()
	
	ok_cut_timestamps.append(Time.get_ticks_msec())
	
func scrap_sheets_until(s):
	var idx = pancake.find(s) + 1
	
	for sheet in pancake.slice(0, idx):
		sheet.scrap()
		ng_cut_timestamps.append(Time.get_ticks_msec())
	
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
	print("ok cut")
	if pancake[0] == triggered_sheet:
		stack_sheet(pancake[0])
		return
	
	scrap_sheets_until(triggered_sheet)

func _on_ng_cut_detected(triggered_sheet):
	print("ng cut")
	scrap_sheets_until(triggered_sheet)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Handle resetting sheets when reaching the right screen boundary
func _process(delta: float) -> void:
	update_scores()
	
	# Remove sheets that move off-screen to the right
	for sheet in pancake:
		if sheet.position.x > screen_width + sheet_spacing:
			pancake.erase(sheet)
			sheet.queue_free()
	
	for sheet in scrapped_sheets:
		if sheet.position.y > screen_height + sheet_spacing:
			scrapped_sheets.erase(sheet)
			sheet.queue_free()

func remove_sheet(s):
	pancake.erase(s)
	s.queue_free()

func update_scores():
	var current_time = Time.get_ticks_msec()
	
	var sample_seconds = 10
	
	ok_cut_timestamps = ok_cut_timestamps.filter(func(timestamp): return current_time - timestamp <= sample_seconds * 1000)
	ng_cut_timestamps = ng_cut_timestamps.filter(func(timestamp): return current_time - timestamp <= sample_seconds * 1000)
	
	var yield_pct = 0.0
	
	var ok_cuts = len(ok_cut_timestamps)
	var ng_cuts = len(ng_cut_timestamps)
	if ok_cuts + ng_cuts > 0:
		yield_pct = float(ok_cuts) / (ok_cuts + ng_cuts) * 100
	
	var ppm = 0
	ppm = ok_cuts * 60 / sample_seconds / stack_capacity
	
	$CanvasLayer/ScoreLabel.text = "Yield: %d%%\nPPM: %d" % [yield_pct, ppm]
	
# Debug
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Mouse clicked at: ", event.position)
