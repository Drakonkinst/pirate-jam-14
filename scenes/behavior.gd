extends Node2D

class_name Behavior

const MIN_DISTANCE_THRESHOLD = 32.0
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

enum State {
	IDLE, WANDER, WALK_TO_EXIT, CONVERSE, INTERACT_CAT
}

@export var max_wander_range: float = 64
@export var min_wander_range: float = 128
@export var min_idle_timer: float = 2
@export var max_idle_timer: float = 5

@export var personality: Personality
@export var move_control: MoveControl

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: Player = get_tree().get_nodes_in_group(GlobalVariables.PLAYER_GROUP)[0]

var nav_map: RID
var state := State.WALK_TO_EXIT
var idle_timer: float = 1 # This value should probably never be 0
var moving_east: bool

func _ready() -> void:
	nav_map = get_world_2d().navigation_map

func update(delta: float) -> void:
	match state:
		State.IDLE:
			move_control.stop_moving()
			if idle_timer > 0:
				idle_timer -= delta
			else:
				idle_timer = 0
				state = State.WALK_TO_EXIT
				
				#var target_pos: Vector2 = _select_random_nearby_pos()
				# Only start moving there if it's a valid position
				#if GlobalVariables.is_valid_navmesh_position(nav_map, target_pos):
					#state = State.WANDER
					#nav_agent.target_position = target_pos
		State.WANDER:
			var to_target : Vector2 = nav_agent.get_next_path_position() - global_position
			move_control.move_in_direction(to_target, delta)
			if to_target.length_squared() < MIN_DISTANCE_THRESHOLD * MIN_DISTANCE_THRESHOLD:
				state = State.IDLE
				idle_timer = _generate_idle_time()
		State.WALK_TO_EXIT:
			# TODO: Currently has no pathfinding
			move_control.move_in_direction(RIGHT if moving_east else LEFT, delta)

func set_moving_east(flag: bool):
	moving_east = flag

func is_moving_east():
	return moving_east

func _select_random_nearby_pos() -> Vector2:
	var distance: float = randf_range(min_wander_range, max_wander_range)
	var angle: float = randf() * PI * 2
	var offset := Vector2(distance * cos(angle), distance * sin(angle))
	var target_pos: Vector2 = global_position + offset
	return target_pos

func _generate_idle_time():
	return randf_range(min_idle_timer, max_idle_timer)
