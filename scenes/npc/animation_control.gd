extends Node2D

class_name AnimationControl

const WALK_LEFT_ANIMATION = "left"
const WALK_RIGHT_ANIMATION = "right"

@onready var model: AnimatedSprite2D = $Model

func _ready() -> void:
	# Face a random direction to start
	var animations: PackedStringArray = model.sprite_frames.get_animation_names()
	model.animation = animations[randi() % animations.size()]
	
func update_animations(velocity: Vector2, locked_facing: bool = false, face_towards: Vector2 = Vector2.ZERO):
	if locked_facing:
		var delta := face_towards - global_position
		if delta.x < 0.0:
			model.animation = WALK_LEFT_ANIMATION
		else:
			model.animation = WALK_RIGHT_ANIMATION
	
	if velocity.is_zero_approx():
		model.frame = 0
		model.stop()
	else:
		if not locked_facing:
			if velocity.x < 0.0:
				model.animation = WALK_LEFT_ANIMATION
			else:
				model.animation = WALK_RIGHT_ANIMATION
		model.play()
