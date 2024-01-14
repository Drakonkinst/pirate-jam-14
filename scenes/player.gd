extends Area2D

const WALK_RIGHT_ANIMATION = "walk"
const WALK_UP_ANIMATION = "up"

signal hit

@export var speed: float = 400 # How fast player will move (pixels/sec)
var screen_size: Vector2 # Size of the game window

# EVENT METHODS (called by other things)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

func _on_body_entered(_body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$PlayerHitbox.set_deferred("disabled", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity := _get_velocity()
	set_pos(position + velocity * delta)
	_update_animations(velocity)

# PUBLIC METHODS

func start(start_pos: Vector2) -> void:
	position = start_pos
	show()
	$PlayerHitbox.disabled = false
	
func set_pos(pos: Vector2) -> void:
	position = pos.clamp(Vector2.ZERO, screen_size)
	
# HELPER METHODS (should all start with underscore)

func _get_velocity() -> Vector2:
	var horizontal_velocity := _get_velocity_multiplier("move_left", "move_right")
	var vertical_velocity := _get_velocity_multiplier("move_up", "move_down")
	var velocity_dir := Vector2(horizontal_velocity, vertical_velocity)	
	if velocity_dir.is_zero_approx():
		return Vector2.ZERO
	else:
		return velocity_dir.normalized() * speed;

func _get_velocity_multiplier(backward_action: String, forward_action: String) -> float:
	var velocity: float = 0.0
	if Input.is_action_pressed(backward_action):
		velocity -= 1.0
	if Input.is_action_pressed(forward_action):
		velocity += 1.0
	return velocity

# Use scene unique node to refer to PlayerModel
func _update_animations(velocity: Vector2) -> void:
	if velocity.is_zero_approx():
		$PlayerModel.stop()
	else:
		$PlayerModel.play()
		if velocity.x != 0:
			$PlayerModel.animation = WALK_RIGHT_ANIMATION
			$PlayerModel.flip_v = false
			$PlayerModel.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$PlayerModel.animation = WALK_UP_ANIMATION
			$PlayerModel.flip_v = velocity.y > 0
