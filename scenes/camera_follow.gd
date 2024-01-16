extends Node2D

class_name CameraFollow

@export var enabled: bool = false
@export var camera: Camera2D
@export var tilemap : TileMap

var y_pos: float

func _ready() -> void:
	y_pos = camera.position.y
	var map_limits: Rect2i = tilemap.get_used_rect()
	var map_cell_size: Vector2i = tilemap.tile_set.tile_size
	camera.limit_left = round(map_limits.position.x * map_cell_size.x * tilemap.scale.x)
	camera.limit_right = round(map_limits.end.x * map_cell_size.x * tilemap.scale.x)
	
func _process(_delta: float) -> void:
	if not enabled:
		return
	var x_pos: float = global_position.x
	camera.position = Vector2(x_pos, y_pos)
