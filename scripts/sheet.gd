extends Node2D

signal sheet_fall_triggered

@export var move_speed: float = 200
var sheet_width: float = 0

var falling = false
var fall_speed = 0
var gravity = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	
	var sprite = $Sprite2D
	if sprite.texture:
		sheet_width = sprite.texture.get_width()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += move_speed * delta
	
	if falling:
		fall_speed += gravity * delta
		position.y += fall_speed * delta

func trigger_fall():
	falling = true

func _on_mouse_entered():
	print("_on_mouse_entered!")
	emit_signal("sheet_fall_triggered", self)
