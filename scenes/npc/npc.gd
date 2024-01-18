extends CharacterBody2D

class_name NPC

@onready var personality: Personality = $Personality
@onready var mood: Mood = $Mood
@onready var move_control: MoveControl = $MoveControl
@onready var animation_control: AnimationControl = $AnimationControl
@onready var behavior: Behavior = $Behavior

@export var nav_control: NavigationControl

func initialize():
	# Set walking speed
	if personality.get_sociable_type() == Personality.Sociable.RUSHED:
		nav_control.randomize_speed(200, 50)
	else:
		nav_control.randomize_speed(100, 50)

func _physics_process(delta: float) -> void:
	behavior.update(delta)
	move_control.update(self, delta)

func _process(_delta: float) -> void:
	animation_control.update_animations(velocity)

func despawn():
	queue_free()