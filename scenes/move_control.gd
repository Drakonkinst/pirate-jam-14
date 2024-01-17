extends Node2D

class_name MoveControl

const MAX_SPEED: float = 300
const MIN_SPEED: float = 50

@export var speed: float = 200.0
@export var acceleration: float = 7.0
var velocity: Vector2

func set_speed(value: float) -> void:
	speed = clamp(value, MIN_SPEED, MAX_SPEED)

func randomize_speed(value: float, variance: float) -> void:
	set_speed(value + randf_range(-variance, variance))

func add_speed(value: float) -> void:
	set_speed(speed + value)

func stop_moving() -> void:
	velocity = Vector2.ZERO
	
func move_in_direction(direction: Vector2, delta: float) -> void:
	move_in_direction_normalized(direction.normalized(), delta)
	
func move_in_direction_normalized(direction_normalized: Vector2, delta: float) -> void:
	velocity = velocity.lerp(direction_normalized * speed, acceleration * delta)

func update(character: CharacterBody2D):
	character.velocity = velocity
	character.move_and_slide()

func get_speed() -> float:
	return speed