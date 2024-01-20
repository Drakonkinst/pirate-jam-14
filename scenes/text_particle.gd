extends Node2D

class_name TextParticle

@export var speed: float = 10
@export var persistent: bool = false

@onready var timer: Timer = $ExpiryTimer
@onready var label: Label = $Label

func set_attributes(text: String, color: Color):
    label.text = text
    label.set("theme_override_colors/font_color", color)

func _physics_process(delta: float) -> void:
    if not persistent:
        position -= Vector2(0, speed * delta)
        var percentage_complete: float = timer.time_left / timer.wait_time
        modulate.a = percentage_complete

func _on_expiry_timer_timeout() -> void:
    if not persistent:
        queue_free()
    timer.stop()
