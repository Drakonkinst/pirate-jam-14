extends Node2D

class_name MoveControl

@export var speed: float = 200.0 # This value is usually overridden
@export var acceleration: float = 7.0
var velocity: Vector2
var target_dir: Vector2

func stop_moving() -> void:
	velocity = Vector2.ZERO
	
func move_in_direction(direction: Vector2) -> void:
	set_target_dir(direction.normalized())
	
func set_target_dir(direction_normalized: Vector2) -> void:
	target_dir = direction_normalized

func update(character: CharacterBody2D, delta: float):
	velocity = velocity.lerp(target_dir * speed, acceleration * delta)
	character.velocity = velocity
	character.move_and_slide()