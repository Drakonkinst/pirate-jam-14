extends Character

const MIN_DISTANCE_THRESHOLD = 4.0

enum State {
	IDLE, WANDER
}

@export var speed: float = 300.0
@export var acceleration: float = 7.0
@export var max_wander_range: float = 64
@export var min_wander_range: float = 128
@export var min_idle_timer: float = 2
@export var max_idle_timer: float = 5
@onready var nav_agent: NavigationAgent2D = $Navigation/NavigationAgent2D
var nav_map: RID
var state := State.IDLE
var idle_timer = _generate_idle_time()

func _ready() -> void:
	# Face a random direction to start
	var animations: PackedStringArray = $NPCModel.sprite_frames.get_animation_names()
	$NPCModel.animation = animations[randi() % animations.size()]
	
	nav_map = get_world_2d().navigation_map

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			if idle_timer > 0:
				idle_timer -= delta
			else:
				idle_timer = 0
				state = State.WANDER
				nav_agent.target_position = _select_random_nearby_pos()
		State.WANDER:
			var to_target : Vector2 = nav_agent.get_next_path_position() - global_position
			var direction = to_target.normalized()
			velocity = velocity.lerp(direction * speed, acceleration * delta)
			if to_target.length_squared() < MIN_DISTANCE_THRESHOLD * MIN_DISTANCE_THRESHOLD:
				state = State.IDLE
				idle_timer = _generate_idle_time()
	move_and_slide()

func _generate_idle_time():
	return randf_range(min_idle_timer, max_idle_timer)

# Bug: This returns (0, 0) if called on initialize
func _select_random_nearby_pos() -> Vector2:
	var distance: float = randf_range(min_wander_range, max_wander_range)
	var angle: float = randf() * PI * 2
	var offset := Vector2(distance * cos(angle), distance * sin(angle))
	var target_pos: Vector2 = global_position + offset
	target_pos = NavigationServer2D.map_get_closest_point(nav_map, target_pos)
	# print(target_pos)
	return target_pos

func _process(_delta: float) -> void:
	_update_animations()

func _update_animations():
	if velocity.is_zero_approx():
		$NPCModel.frame = 0
		$NPCModel.stop()
	else:
		if velocity.x < 0.0:
			$NPCModel.animation = WALK_LEFT_ANIMATION
		elif velocity.x > 0.0:
			$NPCModel.animation = WALK_RIGHT_ANIMATION
		elif velocity.y < 0.0:
			$NPCModel.animation = WALK_UP_ANIMATION
		else:
			$NPCModel.animation = WALK_DOWN_ANIMATION
		$NPCModel.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# queue_free()
	pass
	
func _on_navigation_timer_timeout() -> void:
	# nav_agent.target_position = target_pos
	pass # Replace with function body.
