extends CanvasLayer

class_name HUD

@onready var score_ui: ScoreUI = $ScoreUI

func _on_score_handler_score_changed(value: int) -> void:
    score_ui.set_score(value)
