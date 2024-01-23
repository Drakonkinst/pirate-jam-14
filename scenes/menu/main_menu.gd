extends MarginContainer

class_name MainMenu

@onready var block_out: ColorRect = $BlockOut

signal pressed_game_start
signal pressed_options
signal pressed_credits

func _ready() -> void:
    block_out.hide()

func _on_play_button_pressed() -> void:
    pressed_game_start.emit()

func on_enable() -> void:
    block_out.hide()

func _on_options_button_pressed() -> void:
    block_out.show()
    pressed_options.emit()

func _on_quit_button_pressed() -> void:
    get_tree().quit()

func _on_credits_button_pressed() -> void:
    block_out.show()
    pressed_credits.emit()
