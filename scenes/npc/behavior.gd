extends Node2D

class_name Behavior

const MIN_WANDER_DISTANCE_THRESHOLD: float = 32.0
const MIN_INTERACT_CAT_DISTANCE_THRESHOLD: float = 45.0
const MIN_INTERACT_CONVERSE_DISTANCE_THRESHOLD: float = 50.0
const MAX_NUM_PETS = 2

enum State {
	IDLE, WANDER, WALK_TO_EXIT, CONVERSE, INTERACT_CAT, AVOID
}

signal behavior_tick
signal has_pet_cat

@export var min_idle_timer: float = 2
@export var max_idle_timer: float = 5
@export var max_time_wasted = 30.0

@export var personality: Personality
@export var nav_control: NavigationControl
@export var conversation_control: ConversationControl

@onready var player: Player = get_tree().get_nodes_in_group(GlobalVariables.PLAYER_GROUP)[0]

# Use timer to determine when NPC will want to start conversations
@onready var behavior_timer: Timer = $StartConversationTimer
@onready var start_conversation_timer: Timer = $StartConversationTimer
@onready var avoid_timer: Timer = $AvoidTimer
@onready var start_pet_timer: Timer = $StartPetTimer

var state: State
var idle_timer: float = 1 # This value should probably never be 0
var moving_east: bool
# Can avoid player or NPC
var avoid_target: CharacterBody2D = null
var time_wasted: float = 0.0
var num_pets: int = 0

func _ready():
	# Rushed personalities have less tolerance for time wasted
	if personality.sociable_type == Personality.Sociable.RUSHED:
		max_time_wasted *= 0.25
	
	set_state(State.WALK_TO_EXIT)
	
func update(delta: float) -> void:
	if state != State.WALK_TO_EXIT:
		time_wasted += delta
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
		State.AVOID:
			if avoid_target == null:
				set_state(State.WALK_TO_EXIT)
				return
			nav_control.move(MIN_WANDER_DISTANCE_THRESHOLD)
		State.CONVERSE:
			nav_control.move(MIN_INTERACT_CONVERSE_DISTANCE_THRESHOLD)
			if not is_instance_valid(conversation_control.conversation_target):
				conversation_control.interrupt()
				set_state(State.WALK_TO_EXIT)
		State.INTERACT_CAT:
			var arrived: bool = nav_control.move(MIN_INTERACT_CAT_DISTANCE_THRESHOLD)
			if arrived:
				# Interact with cat
				pet_cat()

func pet_cat() -> void:
	if not start_pet_timer.is_stopped():
		return
	if player.pet():
		num_pets += 1
		has_pet_cat.emit()
		start_pet_timer.start()

# This CAN refresh the avoid state and timer
func start_avoiding(who: CharacterBody2D) -> void:
	avoid_timer.start()
	avoid_target = who
	set_state(State.AVOID)

func set_state(value: State) -> void:
	if state != value:
		state = value
		nav_control.update_state(state)

func set_moving_east(flag: bool):
	moving_east = flag

func should_lock_face():
	return state == State.INTERACT_CAT or state == State.CONVERSE

func get_facing_target():
	if state == State.CONVERSE and conversation_control.in_conversation:
		return conversation_control.get_target_pos()
	else:
		return nav_control.goal_pos

func is_moving_east():
	return moving_east

func _generate_idle_time():
	return randf_range(min_idle_timer, max_idle_timer)

func _on_avoid_timer_timeout() -> void:
	if state == State.AVOID:
		set_state(State.WALK_TO_EXIT)
	avoid_target = null
	avoid_timer.stop()

# Chance multiplier that can be applied
# Goes from 1.0 to 0.0 based on how much time has been "wasted"
func get_time_wasted_multiplier() -> float:
	var multiplier: float = clamp(1.0 - time_wasted / max_time_wasted, 0.0, 1.0)
	return multiplier

func _on_start_pet_timer_timeout() -> void:
	# Chance to stop after every pet
	if num_pets >= randi() % MAX_NUM_PETS + 1 and randf() < get_time_wasted_multiplier():
		set_state(State.WALK_TO_EXIT)
	start_pet_timer.stop()


func _on_update_behavior_timer_timeout() -> void:
	behavior_tick.emit()
