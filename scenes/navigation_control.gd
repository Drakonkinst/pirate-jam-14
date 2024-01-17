extends Node2D

class_name NavigationControl

const WALK_TO_EXIT_LENGTH: float = 100.0
const LEFT := Vector2(-1, 0)
const RIGHT := Vector2(1, 0)

const MAX_SPEED: float = 300
const MIN_SPEED: float = 50

@export var max_wander_range: float = 64
@export var min_wander_range: float = 128

@export var move_control: MoveControl
@export var behavior: Behavior

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: Player = get_tree().get_nodes_in_group(GlobalVariables.PLAYER_GROUP)[0]

var nav_map: RID
var using_nav_agent: bool = true
var target_pos: Vector2

func _ready() -> void:
    nav_map = get_world_2d().navigation_map

func update_state(state: Behavior.State) -> void:
    match state:
        Behavior.State.IDLE:
            move_control.stop_moving()
            using_nav_agent = false
        Behavior.State.INTERACT_CAT:
            _set_target(player.position)
        Behavior.State.WALK_TO_EXIT:
            _set_walk_to_exit_pos()
        Behavior.State.WANDER:
            _set_target(_select_random_wander_pos())

# Return true if arrived at target location, false if moving towards it
func move(stopping_distance: float = 0.0) -> bool:
    if using_nav_agent:
        return _move_to_target(stopping_distance)
    else:
        # Use if position is outside navmesh
        return _move_to_position(target_pos, stopping_distance)

func set_speed(value: float) -> void:
    move_control.speed = clamp(value, MIN_SPEED, MAX_SPEED)
    # Used when calculating avoidance - we don't actually need to set this
    # and it can lead to them being too fast when avoiding
    #nav_agent.set_max_speed(move_control.speed)

func randomize_speed(value: float, variance: float) -> void:
    set_speed(value + randf_range(-variance, variance))

func add_speed(value: float) -> void:
    set_speed(get_speed() + value)

func get_speed() -> float:
    return move_control.speed

func _move_to_target(stopping_distance: float = 0.0) -> bool:
    return _move_to_position(nav_agent.get_next_path_position(), stopping_distance)

func _move_to_position(target: Vector2, stopping_distance: float = 0.0) -> bool:
    #var to_target : Vector2 = target - global_position
    var to_target : Vector2 = to_local(target)
    if to_target.length_squared() < stopping_distance * stopping_distance:
        return true
    if using_nav_agent:
        # Instead of moving in the intended direction, let navigation agent do avoidance first
        var intended_velocity = to_target.normalized() * get_speed()
        nav_agent.set_velocity(intended_velocity)
    else:
        # Just move in the target direction, ignoring avoidance
        move_control.move_in_direction(to_target)
    return false
    
func is_valid_pos(pos: Vector2) -> bool:
    return GlobalVariables.is_valid_navmesh_position(nav_map, pos)

func _set_target(target: Vector2, allow_off_screen := false) -> void:
    var valid_pos: bool = is_valid_pos(target)
    if not valid_pos and not allow_off_screen:
        return
    target_pos = target
    using_nav_agent = valid_pos
    if using_nav_agent:
        nav_agent.set_target_position(target)

func _set_walk_to_exit_pos() -> void:
    var direction: Vector2 = RIGHT if behavior.moving_east else LEFT
    _set_target(global_position + direction * WALK_TO_EXIT_LENGTH, true)

func _select_random_wander_pos() -> Vector2:
    var distance: float = randf_range(min_wander_range, max_wander_range)
    var angle: float = randf() * PI * 2
    var offset := Vector2(distance * cos(angle), distance * sin(angle))
    var target: Vector2 = global_position + offset
    return target

func _on_recalculate_target_timer_timeout() -> void:
    # Update targets for states that need to update them
    # This also recalculates the path
    match behavior.state:
        Behavior.State.INTERACT_CAT:
            _set_target(player.position)
        Behavior.State.WALK_TO_EXIT:
            _set_walk_to_exit_pos()
        Behavior.State.IDLE:
            # Do nothing
            pass
        _:
            # Recalculate path to current target
            _set_target(target_pos)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
    move_control.move_in_direction(safe_velocity)
