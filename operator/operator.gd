class_name OperatorScene
extends Node2D

const DEFAULT_POSITION_X: int = 400
const MOVE_SPEED: int = 300
const MOVE_THRESHOLD: int = 250

var movement_enabled: bool = true
var cutting_enabled: bool = false

var position_x: int = DEFAULT_POSITION_X
var direction: int = 1 # 1 = right, -1 = left
var is_walking: bool = false
var is_cutting: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cutting_sound: AudioStreamPlayer2D = $CuttingSound


func _ready() -> void:
	animated_sprite.animation = "walking"


func _process(delta: float) -> void:
	if movement_enabled and !is_cutting:
		update_position(delta)


func update_position(delta: float) -> void:
	var target_x: float = get_global_mouse_position().x
	var diff_x: float = target_x - position.x
	
	var d: int = sign(diff_x)
	if d != direction:
		animated_sprite.flip_h = d < 0
		direction = d
	
	if abs(diff_x) > MOVE_THRESHOLD:
		position.x += direction * MOVE_SPEED * delta
		play_walking_animation()
	else:
		stop_walking_animation()


func play_walking_animation() -> void:
	if is_walking or is_cutting:
		return
	
	is_walking = true
	animated_sprite.animation = "walking"
	animated_sprite.play()

func stop_walking_animation() -> void:
	if !is_walking:
		return
	
	animated_sprite.animation = "idle"
	animated_sprite.stop()
	is_walking = false

func play_cut_animation() -> void:
	if is_cutting:
		return
		
	is_cutting = true
	cutting_sound.play()
	animated_sprite.animation = "cutting"
	animated_sprite.play()
	is_cutting = false
	

func _on_mouse_entered() -> void:
	play_cut_animation()
