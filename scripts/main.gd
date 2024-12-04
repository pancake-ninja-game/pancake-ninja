extends Node2D

@export var sheet_scene: PackedScene
@export var sheet_spacing: float = 64
@export var spawn_speed: float = 1.0
@export var screen_width: float = 1024
@export var gravity_floor: float = 600

var sheets = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = spawn_speed
	$Timer.start()
	
func _on_Timer_timeout():
	spawn_sheets()

func spawn_sheets():
	print("spawn")
	var new_sheet = sheet_scene.instantiate()
	if sheets.size() > 0:
		# Place new sheet next to the last one
		new_sheet.position.x = sheets[-1].position.x + sheet_spacing
	else:
		new_sheet.position.x = 0
	
	new_sheet.position.y = 100
	add_child(new_sheet)
	sheets.append(new_sheet)
	
	# Set the connection between sheets
	for i in range(1, len(sheets)):
		sheets[i-1].connected_sheets.append(sheets[i])
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Handle resetting sheets when reaching the right screen boundary
func _process(delta: float) -> void:
	for s in sheets:
		if s.position.x > screen_width:
			remove_sheet(s)

func remove_sheet(s):
	sheets.erase(s)
	s.queue_free()
