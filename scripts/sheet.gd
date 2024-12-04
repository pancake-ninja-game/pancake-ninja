extends Node2D

var falling = false
var fall_speed = 200
var gravity = 500
var connected_sheets = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if falling:
		position.y += fall_speed * delta
		fall_speed += gravity * delta
		for s in connected_sheets:
			s.fall_speed = fall_speed
			s.falling = true

func trigger_fall():
	falling = true
	for s in connected_sheets:
		s.trigger_fall()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		trigger_fall()
