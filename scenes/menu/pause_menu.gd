extends CanvasLayer

class_name PauseMenu

signal pressed_quit_to_menu

@export var pause_control: PauseControl

@onready var options_menu: OptionsMenu = $OptionsMenu
@onready var ui_click_audio: AudioStreamPlayer = $UIClickAudio

func _ready() -> void:
    hide()
    options_menu.hide()

func _on_pause_control_unpaused() -> void:
    hide()

func _on_pause_control_paused() -> void:
    show()

func _on_options_button_pressed() -> void:
    options_menu.show()
    ui_click_audio.play()

func _on_options_menu_pressed_back() -> void:
    pass

func _on_resume_button_pressed() -> void:
    pause_control.unpause()

func _on_quit_to_menu_button_pressed() -> void:
    pressed_quit_to_menu.emit()
