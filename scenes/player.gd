extends CharacterBody2D

const WALK_RIGHT_ANIMATION = "walk"
const WALK_UP_ANIMATION = "up"

signal hit

@export var speed: float = 400 # How fast player will move (pixels/sec)
var screen_size: Vector2 # Size of the game window

# EVENT METHODS (called by other things)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	# hide()

func _on_body_entered(_body: Node2D) -> void:
	# hide() # Player disappears after being hit.
	# hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	# $PlayerHitbox.set_deferred("disabled", true)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_update_animations()
	
func _physics_process(_delta: float) -> void:
	velocity = _get_velocity_from_input()
	move_and_slide()
	position = position.clamp(Vector2.ZERO, screen_size)


# PUBLIC METHODS

func start(start_pos: Vector2) -> void:
	position = start_pos
	show()
	$PlayerHitbox.disabled = false
	
# HELPER METHODS (should all start with underscore)

func _get_velocity_from_input() -> Vector2:
	var velocity_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if velocity_dir.is_zero_approx():
		return Vector2.ZERO
	else:
		return velocity_dir.normalized() * speed;

# Use scene unique node to refer to PlayerModel
func _update_animations() -> void:
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
