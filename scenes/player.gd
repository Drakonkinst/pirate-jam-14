extends CharacterBody2D

class_name Player

const WALK_DOWN_ANIMATION = "down"
const WALK_UP_ANIMATION = "up"
const WALK_LEFT_ANIMATION = "left"
const WALK_RIGHT_ANIMATION = "right"

signal hit

@export var speed: float = 400 # How fast player will move (pixels/sec)
@export var tilemap: TileMap # Optional tilemap to determine player bounds

var min_bound: Vector2 = Vector2(-INF, -INF)
var max_bound: Vector2 = Vector2(INF, INF)

# EVENT METHODS (called by other things)

func _ready() -> void:
	hide()
	if is_instance_valid(tilemap):
		_calc_bounds_from_tilemap()

func _process(_delta: float) -> void:
	_update_animations()
	
func _physics_process(_delta: float) -> void:
	velocity = _get_velocity_from_input()
	move_and_slide()
	position = position.clamp(min_bound, max_bound)

# PUBLIC METHODS

func initialize(start_pos: Vector2) -> void:
	position = start_pos
	show()
	
# HELPER METHODS (should all start with underscore)

func _calc_bounds_from_tilemap() -> void:
	var map_limits: Rect2i = tilemap.get_used_rect()
	var map_cell_size: Vector2i = tilemap.tile_set.tile_size
	min_bound = Vector2(round(map_limits.position.x * map_cell_size.x * tilemap.scale.x), round(map_limits.position.y * map_cell_size.y * tilemap.scale.y))
	max_bound = Vector2(round(map_limits.end.x * map_cell_size.x * tilemap.scale.x), round(map_limits.end.y * map_cell_size.y * tilemap.scale.y))
	
func _get_velocity_from_input() -> Vector2:
	var velocity_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if velocity_dir.is_zero_approx():
		return Vector2.ZERO
	else:
		return velocity_dir.normalized() * speed;

func _update_animations():
	if velocity.is_zero_approx():
		$PlayerModel.frame = 0
		$PlayerModel.stop()
	else:
		if velocity.x < 0.0:
			$PlayerModel.animation = WALK_LEFT_ANIMATION
		elif velocity.x > 0.0:
			$PlayerModel.animation = WALK_RIGHT_ANIMATION
		elif velocity.y < 0.0:
			$PlayerModel.animation = WALK_UP_ANIMATION
		else:
			$PlayerModel.animation = WALK_DOWN_ANIMATION
		$PlayerModel.play()
