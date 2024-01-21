extends Node2D

class_name PauseControl

const PAUSE_INPUT := "pause"

signal paused
signal unpaused

func _input(event) -> void:
    if event.is_action_pressed(PAUSE_INPUT):
        _toggle_pause()

func _toggle_pause() -> void:
    var is_paused: bool = get_tree().paused
    get_tree().paused = not is_paused
    if is_paused:
        unpaused.emit()
    else:
        paused.emit()

func pause() -> void:
    if get_tree().paused:
        return
    _toggle_pause()