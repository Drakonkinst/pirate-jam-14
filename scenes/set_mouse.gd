extends Node2D

@export var default_image: CompressedTexture2D

func _ready() -> void:
    Input.set_custom_mouse_cursor(default_image)

