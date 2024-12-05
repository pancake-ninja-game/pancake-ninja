extends Node2D

@export var move_speed: float = 150
@export var sprite_idle: Texture2D
@export var sprite_walking: Texture2D
@export var sprite_walking_alt: Texture2D
@export var sprite_cutting: Texture2D

var current_direction: int = 1 # -1 = left, 1 = right
var walking_state: bool = false
var is_walking: bool = false
var is_cutting: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = sprite_idle
	
	var walk_timer = Timer.new()
	walk_timer.wait_time = 0.15
	walk_timer.one_shot = false
	walk_timer.autostart = true
	walk_timer.connect("timeout", Callable(self, "_on_walk_timer_timeout"))
	add_child(walk_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_cutting:
		return
	
	var target_x = get_global_mouse_position().x
	var diff_x = target_x - position.x
	
	# Flip sprite if direction changes
	var direction = sign(diff_x)
	if direction != current_direction:
		$Sprite2D.flip_h = direction < 0
		current_direction = direction
	
	# Start walking if the operator is too far away from the mouse
	if abs(diff_x) > 200:
		is_walking = true
		position.x += direction * move_speed * delta
	else:
		is_walking = false
		$Sprite2D.texture = sprite_idle

func play_cutting_animation():
	if is_cutting:
		return
		
	is_cutting = true
	$CutSound.play()
	$Sprite2D.texture = sprite_cutting
	await get_tree().create_timer(0.2).timeout
	is_cutting = false
	$Sprite2D.texture = sprite_idle

func _on_walk_timer_timeout():
	if is_walking:
		walking_state = !walking_state
		$Sprite2D.texture = sprite_walking if walking_state else sprite_walking_alt
