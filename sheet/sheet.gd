class_name SheetScene
extends Node2D

signal sheet_cut(sheet: SheetScene, ok: bool)
signal sheet_missed(sheet: SheetScene)

const OK_AREA_IDX: int = 0
const NG_AREA_IDX: int = 1

var is_cutting: bool = false
var is_moving_to_stack: bool = false
var is_stacked: bool = false
var is_dropped: bool = false

var max_rotation: float = 10
var max_skew: float = 3
var speed_x: float
var speed_y: float
var target_pos: Vector2

var ok_cut: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var ok_area: CollisionShape2D = $OkArea
@onready var ng_area: CollisionShape2D = $NgArea

@onready var speed_rotation: float = randf_range(-max_rotation, max_rotation)
@onready var speed_skew: float = randf_range(-max_skew, max_skew)
@onready var width: int = sprite.texture.get_width()


func _process(delta: float) -> void:
	if is_stacked or is_moving_to_stack:
		if is_moving_to_stack:
			position = position.lerp(target_pos, delta * 2)
			scale = scale.lerp(Vector2(0.5, 0.3), delta * 2)
			
			# Stop the movement when it's at target position
			if position.distance_to(target_pos) < 1:
				is_moving_to_stack = false
				is_stacked = true
		
		return
	
	position.x += speed_x * delta
	
	if is_dropped:
		update_y_position(delta)
	
	if position.x > globals.WINDOW_WIDTH + globals.sheet_width:
		sheet_missed.emit(self)
		
	if position.y > globals.WINDOW_HEIGHT + globals.sheet_height:
		self.queue_free()


func move_to_stack(pos: Vector2) -> void:
	target_pos = pos
	is_moving_to_stack = true


func drop() -> void:
	is_dropped = true


func update_y_position(delta: float) -> void:
	speed_y += globals.GRAVITY * delta
	position.y += speed_y * delta
	
	rotation += rotation * delta
	skew += speed_skew * delta


func _on_mouse_entered() -> void:
	is_cutting = true


func _on_mouse_exited() -> void:
	is_cutting = false
	sheet_cut.emit(self, ok_cut)


func _on_mouse_shape_entered(shape_idx: int) -> void:
	if shape_idx == NG_AREA_IDX:
		ok_cut = false


func _on_line_speed_changed(speed: float) -> void:
	speed_x = speed
