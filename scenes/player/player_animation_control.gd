extends AnimationControl

class_name PlayerAnimationControl

func update_animations(velocity: Vector2):
    if velocity.is_zero_approx():
        model.frame = 0
        model.stop()
    else:
        if velocity.x < 0.0:
            model.animation = WALK_LEFT_ANIMATION
        elif velocity.x > 0.0:
            model.animation = WALK_RIGHT_ANIMATION
        model.play()
