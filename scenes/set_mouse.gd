extends Node2D

@export var default_image: CompressedTexture2D

func _ready() -> void:
    Input.set_custom_mouse_cursor(default_image, Input.CURSOR_ARROW, Vector2(default_image.get_width() * 1.0 / 2, default_image.get_height() * 1.0 / 2))

