extends Node2D

class_name NavigationControl

enum AvoidanceBit { OTHER_NPC = 1, PLAYER = 2 }

const WALK_TO_EXIT_LOOKAHEAD: float = 100.0
const AVOID_LOOKAHEAD: float = 150.0
const LEFT := Vector2(-1, 0)
const RIGHT := Vector2(1, 0)

const MAX_SPEED: float = 300
const MIN_SPEED: float = 50
const ALERT_BONUS: float = 25

@export var max_wander_range: float = 64
@export var min_wander_range: float = 128

@export var move_control: MoveControl
@export var behavior: Behavior
@export var nav_agent: NavigationAgent2D

@onready var player: Player = get_tree().get_nodes_in_group(GlobalVariables.PLAYER_GROUP)[0]

var nav_map: RID
var using_nav_agent: bool = true
var goal_pos: Vector2
var base_speed: float

func _ready() -> void:
    nav_map = get_world_2d().navigation_map

# Called every time state changes
func update_state(state: Behavior.State) -> void:
    nav_agent.set_avoidance_mask_value(AvoidanceBit.PLAYER, true)
    set_speed_with_modifier(ALERT_BONUS if _is_alert_behavior(state) else 0.0)
    match state:
        Behavior.State.IDLE:
            move_control.stop_moving()
            using_nav_agent = false
        Behavior.State.INTERACT_CAT:
            # Stop avoiding the player
            nav_agent.set_avoidance_mask_value(AvoidanceBit.PLAYER, false)
            _set_goal(player.global_position, true)
        Behavior.State.WALK_TO_EXIT:
            _set_walk_to_exit_pos()
        Behavior.State.WANDER:
            _set_goal(_select_random_wander_pos())
        Behavior.State.AVOID:
            if behavior.avoid_target != null:
                _set_goal(_select_avoid_pos(behavior.avoid_target), false)

# Return true if they should speed up, based on the given state
func _is_alert_behavior(state: Behavior.State):
    return state == Behavior.State.INTERACT_CAT or state == Behavior.State.AVOID

# Return true if arrived at target location, false if moving towards it
func move(stopping_distance: float = 0.0) -> bool:
    if using_nav_agent:
        return _move_to_target(stopping_distance)
    else:
        # Use if position is outside navmesh
        return _move_to_position(goal_pos, stopping_distance)

func set_speed_with_modifier(value: float = 0.0) -> void:
    move_control.speed = clamp(base_speed + value, MIN_SPEED, MAX_SPEED)

func set_base_speed(value: float) -> void:
    base_speed = value
    move_control.speed = clamp(value, MIN_SPEED, MAX_SPEED)
    # Used when calculating avoidance - we don't actually need to set this
    # and it can lead to them being too fast when avoiding
    #nav_agent.set_max_speed(move_control.speed)

func randomize_base_speed(value: float, variance: float) -> void:
    set_base_speed(value + randf_range(-variance, variance))

func add_base_speed(value: float) -> void:
    set_base_speed(get_speed() + value)

func get_speed() -> float:
    return move_control.speed

func get_base_speed() -> float:
    return base_speed

func _move_to_target(stopping_distance: float = 0.0) -> bool:
    return _move_to_position(nav_agent.get_next_path_position(), stopping_distance)

func _move_to_position(target: Vector2, stopping_distance: float = 0.0) -> bool:
    var to_goal: Vector2 = goal_pos - global_position
    if to_goal.length_squared() < stopping_distance * stopping_distance:
        if using_nav_agent:
            nav_agent.set_velocity(Vector2.ZERO)
        else:
            move_control.stop_moving()
        return true
    var to_target : Vector2 = target - global_position
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

func _set_goal(target: Vector2, allow_off_screen := false) -> void:
    var valid_pos: bool = is_valid_pos(target)
    if not valid_pos and not allow_off_screen:
        return
    goal_pos = target
    using_nav_agent = valid_pos
    if using_nav_agent:
        nav_agent.set_target_position(target)

func _set_walk_to_exit_pos() -> void:
    var direction: Vector2 = RIGHT if behavior.moving_east else LEFT
    _set_goal(global_position + direction * WALK_TO_EXIT_LOOKAHEAD, true)

func _select_random_wander_pos() -> Vector2:
    var distance: float = randf_range(min_wander_range, max_wander_range)
    var angle: float = randf() * PI * 2
    var offset := Vector2(distance * cos(angle), distance * sin(angle))
    var target: Vector2 = global_position + offset
    return target

func _select_avoid_pos(avoid: CharacterBody2D) -> Vector2:
    var to_avoid: Vector2 = avoid.global_position - global_position
    var avoid_dir: Vector2 = (-to_avoid).normalized()
    var ideal_avoid_pos: Vector2 = global_position + AVOID_LOOKAHEAD * avoid_dir
    # Add some randomized y-offset so they can continue their path more easily
    ideal_avoid_pos += Vector2(0.0, _random_sign() * randf_range(AVOID_LOOKAHEAD / 2, AVOID_LOOKAHEAD))
    return GlobalVariables.get_nearest_point_on_map(nav_map, ideal_avoid_pos)

func _random_sign() -> int:
    return randi() % 2 - 1

func _on_recalculate_target_timer_timeout() -> void:
    # Update targets for states that need to update them
    # This also recalculates the path
    match behavior.state:
        Behavior.State.INTERACT_CAT:
            _set_goal(player.global_position, true)
        Behavior.State.WALK_TO_EXIT:
            _set_walk_to_exit_pos()
        Behavior.State.IDLE:
            # Do nothing
            pass
        Behavior.State.AVOID:
            if behavior.avoid_target != null:
                _set_goal(_select_avoid_pos(behavior.avoid_target), false)
        _:
            # Recalculate path to current target
            _set_goal(goal_pos)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
    move_control.move_in_direction(safe_velocity)
