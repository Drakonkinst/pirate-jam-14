extends Node2D

class_name Behavior

const MIN_WANDER_DISTANCE_THRESHOLD: float = 32.0
const MIN_INTERACT_CAT_DISTANCE_THRESHOLD: float = 16.0

enum State {
	IDLE, WANDER, WALK_TO_EXIT, CONVERSE, INTERACT_CAT
}

@export var min_idle_timer: float = 2
@export var max_idle_timer: float = 5

@export var personality: Personality
@onready var nav_control: NavigationControl = $NavigationControl

var state := State.WALK_TO_EXIT
var idle_timer: float = 1 # This value should probably never be 0
var moving_east: bool

func update(delta: float) -> void:
	match state:
		State.IDLE:
			if idle_timer > 0:
				idle_timer -= delta
			else:
				idle_timer = 0
				state = State.WALK_TO_EXIT
		State.WANDER:
			var arrived: bool = nav_control.move(delta, MIN_WANDER_DISTANCE_THRESHOLD)
			if arrived:
				state = State.IDLE
				idle_timer = _generate_idle_time()
		State.WALK_TO_EXIT:
			nav_control.move(delta)
		State.INTERACT_CAT:
			var arrived: bool = nav_control.move(delta, MIN_INTERACT_CAT_DISTANCE_THRESHOLD)
			if arrived:
				# Interact with cat
				pass
			
func set_state(value: State) -> void:
	state = value
	nav_control.update_state(state)

func set_moving_east(flag: bool):
	moving_east = flag

func is_moving_east():
	return moving_east

func _generate_idle_time():
	return randf_range(min_idle_timer, max_idle_timer)
