extends AnimationControl

class_name PlayerAnimationControl

const SIT_LEFT_ANIMATION = "sit_left"
const SIT_RIGHT_ANIMATION = "sit_right"
const SIT_UP_ANIMATION = "sit_up"
const SIT_DOWN_ANIMATION = "sit_down"
const WALK_UP_ANIMATION = "up"
const WALK_DOWN_ANIMATION = "down"

enum Facing { UP, DOWN, LEFT, RIGHT }

var facing: Facing = Facing.RIGHT

func _ready() -> void:
    model.animation = SIT_RIGHT_ANIMATION
    model.frame = 5
    model.play()

# Player is never locked to facing, so these params can be ignored
func update_animations(velocity: Vector2, _locked_facing: bool = false, _face_towards: Vector2 = Vector2.ZERO):

    if velocity.is_zero_approx():
        match facing:
            Facing.RIGHT:
                model.animation = SIT_RIGHT_ANIMATION
            Facing.LEFT:
                model.animation = SIT_LEFT_ANIMATION
            Facing.UP:
                model.animation = SIT_UP_ANIMATION
            Facing.DOWN:
                model.animation = SIT_DOWN_ANIMATION
    else:
        if velocity.x < 0.0:
            model.animation = WALK_LEFT_ANIMATION
            facing = Facing.LEFT
        elif velocity.x > 0.0:
            model.animation = WALK_RIGHT_ANIMATION
            facing = Facing.RIGHT
        elif velocity.y > 0.0:
            model.animation = WALK_DOWN_ANIMATION
            facing = Facing.DOWN
        elif velocity.y < 0.0:
            model.animation = WALK_UP_ANIMATION
            facing = Facing.UP
        model.play()
