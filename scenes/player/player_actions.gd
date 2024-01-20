extends Node2D

class_name PlayerActions

const MEOW_INPUT := "meow"
const HISS_INPUT := "hiss"

enum Action {
    MEOW, HISS
}

# https://docs.godotengine.org/en/latest/tutorials/scripting/instancing_with_signals.html
signal made_noise(action: Action, direction: float, origin: Vector2)

@onready var noise_cooldown: Timer = $NoiseCooldownTimer

func _input(event) -> void:
    if event.is_action_pressed(MEOW_INPUT):
        _attempt_make_noise(Action.MEOW)
    elif event.is_action_pressed(HISS_INPUT):
        _attempt_make_noise(Action.HISS)

func _attempt_make_noise(action: Action) -> void:
    if not noise_cooldown.is_stopped():
        return
    var direction: Vector2 = get_global_mouse_position() - global_position
    made_noise.emit(action, direction.angle(), global_position)
    noise_cooldown.start()

func _on_noise_cooldown_timer_timeout() -> void:
    noise_cooldown.stop()
