extends Node2D

class_name PlayerActions

const MEOW_INPUT := "meow"
const HISS_INPUT := "hiss"

enum Action {
    MEOW, HISS
}

# https://docs.godotengine.org/en/latest/tutorials/scripting/instancing_with_signals.html
signal made_noise(action: Action, direction: float, origin: Vector2)

# TODO: Joint cooldown

func _input(event):
    if event.is_action_pressed(MEOW_INPUT):
        _attempt_make_noise(Action.MEOW)
    elif event.is_action_pressed(HISS_INPUT):
        _attempt_make_noise(Action.HISS)

func _attempt_make_noise(action: Action):
    var direction: Vector2 = get_global_mouse_position() - global_position
    print(get_viewport().get_mouse_position(), ", ", global_position)
    made_noise.emit(action, direction.angle(), global_position)