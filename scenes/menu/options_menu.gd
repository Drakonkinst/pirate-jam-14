extends MarginContainer

class_name OptionsMenu

signal pressed_back

@export var music_slider: HSlider
@export var effects_slider: HSlider
@onready var ui_click_audio: AudioStreamPlayer = $UIClickAudio

func _ready() -> void:
    music_slider.value = GlobalVariables.get_music_volume()
    effects_slider.value = GlobalVariables.get_effects_volume()
    
func _on_back_button_pressed() -> void:
    pressed_back.emit()
    ui_click_audio.play()
    hide()


func _on_music_slider_mouse_exited() -> void:
    release_focus()

func _on_effects_slider_mouse_exited() -> void:
    release_focus()
    
func _on_music_slider_value_changed(value: float) -> void:
    GlobalVariables.set_music_volume(value)

func _on_effects_slider_value_changed(value: float) -> void:
    GlobalVariables.set_effects_volume(value)
