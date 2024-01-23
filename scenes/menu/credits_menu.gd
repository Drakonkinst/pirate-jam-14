extends MarginContainer

class_name CreditsMenu

signal pressed_back

func _on_back_button_pressed() -> void:
    pressed_back.emit()
    hide()