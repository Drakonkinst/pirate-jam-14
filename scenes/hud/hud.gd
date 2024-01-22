extends CanvasLayer

class_name HUD

@export_group("External")
@export var time_remaining: Timer

@export_group("Internal")
@export var time_remaining_bar: TextureProgressBar
@onready var score_ui: ScoreUI = $ScoreUI

func _process(_delta: float) -> void:
    var progress := time_remaining.time_left / time_remaining.wait_time
    time_remaining_bar.value = time_remaining_bar.min_value + (time_remaining_bar.max_value - time_remaining_bar.min_value) * progress
    
func _on_score_handler_score_changed(value: int) -> void:
    score_ui.set_score(value)
