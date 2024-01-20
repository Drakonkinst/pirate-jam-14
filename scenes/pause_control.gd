extends Node2D

const PAUSE_INPUT := "pause"

signal pause
signal unpause
func _input(event) -> void:
    if event.is_action_pressed(PAUSE_INPUT):
        _toggle_pause()

func _toggle_pause() -> void:
    var is_paused: bool = get_tree().paused
    get_tree().paused = not is_paused
    if is_paused:
        unpause.emit()
    else:
        pause.emit()
