extends CanvasLayer

func _ready() -> void:
    hide()

func _on_pause_control_unpaused() -> void:
    hide()

func _on_pause_control_paused() -> void:
    show()
