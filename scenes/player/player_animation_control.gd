extends AnimationControl

class_name PlayerAnimationControl

# Player is never locked to facing, so these params can be ignored
func update_animations(velocity: Vector2, _locked_facing: bool = false, _face_towards: Vector2 = Vector2.ZERO):
    if velocity.is_zero_approx():
        model.frame = 0
        model.stop()
    else:
        if velocity.x < 0.0:
            model.animation = WALK_LEFT_ANIMATION
        elif velocity.x > 0.0:
            model.animation = WALK_RIGHT_ANIMATION
        model.play()
