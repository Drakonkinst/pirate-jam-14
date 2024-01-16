extends Node2D

class_name CameraFollow

@export var camera: Camera2D
@export var left_bound: Marker2D
@export var right_bound: Marker2D

var y_pos: float
func _ready() -> void:
	y_pos = camera.position.y
	
func _process(_delta: float) -> void:
	# Always use original camera y position
	#var camera_viewport = get_viewport().get_visible_rect().size
	#print(global_position.x, " ", left_bound.position.x, " ", right_bound.position.x, " ", camera_viewport.x)
	var x_pos: float = clamp(global_position.x, left_bound.position.x, right_bound.position.x)
	camera.position = Vector2(x_pos, y_pos)
