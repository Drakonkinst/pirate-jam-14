extends Node2D

class_name DialogueControl

@export var dialogue_label: Label
@export var text_speed: float = 20.0

@onready var hide_timer: Timer = $HideTimer

var showing_text := false

func _ready() -> void:
    hide()

func _process(delta: float) -> void:
    if visible:
        dialogue_label.visible_ratio = clamp(dialogue_label.visible_ratio + (1.0 / dialogue_label.text.length()) * delta * text_speed, 0.0, 1.0)
        if dialogue_label.visible_ratio >= 1.0 and hide_timer.is_stopped():
            hide_timer.start()
    
func play_text(line: String) -> void:
    dialogue_label.text = line
    dialogue_label.visible_ratio = 0.0
    showing_text = true
    show()

func is_showing_text() -> bool:
    return showing_text

func _on_hide_timer_timeout() -> void:
    showing_text = false
    hide()
    hide_timer.stop() 
