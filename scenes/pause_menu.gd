extends CanvasLayer

func _ready() -> void:
    hide()

func _on_pause_control_unpause() -> void:
    hide()

func _on_pause_control_pause() -> void:
    show()
