extends Node2D

class_name MoveControl

@export var speed: float = 300.0
@export var acceleration: float = 7.0
var velocity: Vector2

func stop_moving() -> void:
	velocity = Vector2.ZERO
	
func move_in_direction(direction: Vector2, delta: float) -> void:
	move_in_direction_normalized(direction.normalized(), delta)
	
func move_in_direction_normalized(direction_normalized: Vector2, delta: float) -> void:
	velocity = velocity.lerp(direction_normalized * speed, acceleration * delta)

func update(character: CharacterBody2D):
	character.velocity = velocity
	character.move_and_slide()