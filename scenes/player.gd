extends Character

const WALK_DOWN_ANIMATION = "down"
const WALK_UP_ANIMATION = "up"
const WALK_LEFT_ANIMATION = "left"
const WALK_RIGHT_ANIMATION = "right"

signal hit

@export var speed: float = 400 # How fast player will move (pixels/sec)

# EVENT METHODS (called by other things)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# hide()
	pass

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
