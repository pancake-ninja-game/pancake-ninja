extends Node2D

signal ok_cut_detected
signal ng_cut_detected

@export var move_speed: float = 200
@export var gravity: float = 2000
@export var rotation_speed: float = 10
@export var skew_speed: float = 3

var sheet_width: float = 0

var is_falling = false
var fall_speed = 0
var rotation_direction: float = 0
var skew_direction: float = 0

var is_hovering = false
var mouse_positions = []

var cut_zone: float = 0.15

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	
	# Randomize drift and rotation direction
	rotation_direction = randf_range(-rotation_speed, rotation_speed)
	skew_direction = randf_range(-skew_speed, skew_speed)
	
	var sprite = $Sprite2D
	if sprite.texture:
		sheet_width = sprite.texture.get_width()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += move_speed * delta
	
	if is_falling:
		fall_speed += gravity * delta
		position.y += fall_speed * delta
		
		rotation += rotation_direction * delta
		skew += skew_direction * delta
	
	if is_hovering:
		var pos_x = get_global_mouse_position().x - position.x
		mouse_positions.append(pos_x)

func trigger_fall():
	is_falling = true

func _on_mouse_entered():
	if is_falling:
		return
		
	is_hovering = true
	mouse_positions.clear()

func _on_mouse_exited():
	if is_falling:
		return
		
	is_hovering = false
	evaluate_cut()
	
func evaluate_cut():
	var left_boundary = -sheet_width * cut_zone
	var right_boundary = sheet_width * cut_zone
	
	for pos in mouse_positions:
		if pos < left_boundary or pos > right_boundary:
			emit_signal("ng_cut_detected", self)
			return
		
	emit_signal("ok_cut_detected", self)
