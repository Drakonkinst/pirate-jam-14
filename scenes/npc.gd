extends CharacterBody2D

class_name NPC

@onready var personality: Personality = $Personality
@onready var mood: Mood = $Mood
@onready var move_control: MoveControl = $MoveControl
@onready var animation_control: AnimationControl = $AnimationControl
@onready var behavior: Behavior = $Behavior

func initialize():
	# Set walking speed
	if personality.get_sociable_type() == Personality.Sociable.RUSHED:
		move_control.randomize_speed(200, 50)
	else:
		move_control.randomize_speed(100, 50)

func _physics_process(delta: float) -> void:
	behavior.update(delta)
	move_control.update(self)

func _process(_delta: float) -> void:
	animation_control.update_animations(velocity)

func despawn():
	queue_free()