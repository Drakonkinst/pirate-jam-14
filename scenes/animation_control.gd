extends Node2D

class_name AnimationControl

const WALK_DOWN_ANIMATION = "down"
const WALK_UP_ANIMATION = "up"
const WALK_LEFT_ANIMATION = "left"
const WALK_RIGHT_ANIMATION = "right"

@onready var model: AnimatedSprite2D = $Model

func _ready() -> void:
	# Face a random direction to start
	var animations: PackedStringArray = model.sprite_frames.get_animation_names()
	model.animation = animations[randi() % animations.size()]
	
func update_animations(velocity: Vector2):
	if velocity.is_zero_approx():
		model.frame = 0
		model.stop()
	else:
		if velocity.x < 0.0:
			model.animation = WALK_LEFT_ANIMATION
		elif velocity.x > 0.0:
			model.animation = WALK_RIGHT_ANIMATION
		elif velocity.y < 0.0:
			model.animation = WALK_UP_ANIMATION
		else:
			model.animation = WALK_DOWN_ANIMATION
		model.play()
