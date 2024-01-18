extends Node2D

class_name Behavior

const MIN_WANDER_DISTANCE_THRESHOLD: float = 32.0
const MIN_INTERACT_CAT_DISTANCE_THRESHOLD: float = 45.0

enum State {
	IDLE, WANDER, WALK_TO_EXIT, CONVERSE, INTERACT_CAT, AVOID
}

@export var min_idle_timer: float = 2
@export var max_idle_timer: float = 5

@export var personality: Personality
@export var nav_control: NavigationControl

@onready var player: Player = get_tree().get_nodes_in_group(GlobalVariables.PLAYER_GROUP)[0]

var state: State
var idle_timer: float = 1 # This value should probably never be 0
var moving_east: bool
# Can avoid player or NPC
var avoid_target: CharacterBody2D = null
var time_since_spawn: float = 0

func _ready():
	set_state(State.WALK_TO_EXIT)
	
func update(delta: float) -> void:
	time_since_spawn += delta
	match state:
		State.IDLE:
			if idle_timer > 0:
				idle_timer -= delta
			else:
				idle_timer = 0
				state = State.WALK_TO_EXIT
		State.WANDER:
			var arrived: bool = nav_control.move(MIN_WANDER_DISTANCE_THRESHOLD)
			if arrived:
				state = State.IDLE
				idle_timer = _generate_idle_time()
		State.WALK_TO_EXIT:
			nav_control.move(delta)
		State.INTERACT_CAT:
			var arrived: bool = nav_control.move(MIN_INTERACT_CAT_DISTANCE_THRESHOLD)
			if arrived:
				player.pet()
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

func _on_update_behavior_timer_timeout() -> void:
	# TODO: Chance to attempt to start conversation if NPC is nearby (lower if late)
	# TODO: If paying attention to cat, chance to stop (higher if late)
	# TODO: If cat lover, check if player is nearby and chance to try to go to them without prompting
	# TODO: If allergic, check if player is nearby and react
	pass # Replace with function body.
