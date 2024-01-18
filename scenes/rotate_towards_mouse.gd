extends Node2D

@export var origin: Node2D

func _process(_delta: float) -> void:
    var direction: Vector2 = get_global_mouse_position() - global_position
    rotation = direction.angle()