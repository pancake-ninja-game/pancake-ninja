extends Node2D

@export var sheet_scene: PackedScene
@export var screen_width: float = 1024

var sheet_spacing: float = 0
var sheet_speed: float = 200
var sheets = []

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

func _on_Timer_timeout():
	spawn_sheet()
	
func spawn_sheet():
	var s = sheet_scene.instantiate()
	s.position = Vector2(-sheet_spacing, 100)
	add_child(s)
	sheets.append(s)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Handle resetting sheets when reaching the right screen boundary
func _process(delta: float) -> void:
	# Remove sheets that move off-screen to the right
	for s in sheets:
		if s.position.x > screen_width + sheet_spacing:
			remove_sheet(s)

func remove_sheet(s):
	sheets.erase(s)
	s.queue_free()
