extends MarginContainer

class_name LevelSelectMenu

signal level_selected
signal pressed_back

@onready var ui_click_audio: AudioStreamPlayer = $UIClickAudio

var selected := false # Ensure this can only be pressed once per instance

func _on_back_button_pressed() -> void:
    pressed_back.emit()
    ui_click_audio.play()
    hide()

func _set_level(level: int) -> void:
    if selected:
        return
    GlobalVariables.next_level_index = level - 1
    level_selected.emit()
    ui_click_audio.play()
    selected = true

func _on_level_button_1_pressed() -> void:
    _set_level(1)

func _on_level_button_2_pressed() -> void:
    _set_level(2)

func _on_level_button_3_pressed() -> void:
    _set_level(3)

func _on_level_button_4_pressed() -> void:
    _set_level(4)

func _on_level_button_5_pressed() -> void:
    _set_level(5)

func _on_level_button_6_pressed() -> void:
    _set_level(6)

func _on_level_button_7_pressed() -> void:
    _set_level(7)
    
func _on_level_button_8_pressed() -> void:
    _set_level(8)
