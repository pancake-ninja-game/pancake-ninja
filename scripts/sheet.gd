extends Node2D

signal ok_cut_detected
signal ng_cut_detected

@export var move_speed: float = 200
@export var gravity: float = 2000
@export var rotation_speed: float = 10
@export var skew_speed: float = 3

var sheet_width: float = 0

var sheet_height_in_jr: float = 5

var is_scrapped = false
var fall_speed = 0
var rotation_direction: float = 0
var skew_direction: float = 0

var is_hovering = false
var mouse_positions = []

var cut_zone: float = 0.3

var is_stacked = false
static var jr_pos: Vector2 = Vector2(1100, 600)
static var jr_height: float = 0
var target_pos: Vector2

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
	
	if is_scrapped:
		fall_speed += gravity * delta
		position.y += fall_speed * delta
		
		rotation += rotation_direction * delta
		skew += skew_direction * delta
		return
	
	if is_stacked:
		move_toward_jr(delta)
		return
	
	if is_hovering:
		var pos_x = get_global_mouse_position().x - position.x
		mouse_positions.append(pos_x)
		return

func scrap():
	is_scrapped = true

func _on_mouse_entered():
	if is_stacked or is_scrapped:
		return
		
	is_hovering = true
	mouse_positions.clear()

func _on_mouse_exited():
	if is_stacked or is_scrapped:
		return
		
	is_hovering = false
	evaluate_cut()
	
func evaluate_cut():
	var left_boundary = -sheet_width / 2
	var right_boundary = -sheet_width / 2 + sheet_width * cut_zone
	
	for pos in mouse_positions:
		if pos < left_boundary or pos > right_boundary:
			emit_signal("ng_cut_detected", self)
			return
	
	emit_signal("ok_cut_detected", self)

func stack_in_jr():
	is_stacked = true
	move_speed = 0
	fall_speed = 0
	
	target_pos = jr_pos - Vector2(0, jr_height)
	jr_height += sheet_height_in_jr

func move_toward_jr(delta):
	position = position.lerp(target_pos, delta * 2)
	scale = scale.lerp(Vector2(0.5, 0.5), delta * 2)
	
	# Stop the movement when it's at target position
	if position.distance_to(target_pos) < 5:
		is_stacked = false
		rotation = 0
		skew_direction = 0
		scale = Vector2(0.5, 0.5)

func reset_jr_height():
	jr_height = 0
