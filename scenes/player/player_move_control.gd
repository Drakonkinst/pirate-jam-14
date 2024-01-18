extends Node2D

class_name PlayerMoveControl

@export var speed: float = 350 # How fast player will move (pixels/sec)

var min_bound: Vector2 = Vector2(-INF, -INF)
var max_bound: Vector2 = Vector2(INF, INF)

func initialize(ref_tilemap: TileMap):
   if is_instance_valid(ref_tilemap):
        _calc_bounds_from_tilemap(ref_tilemap) 

func update(character: CharacterBody2D, _delta: float) -> void:
    character.velocity = _get_velocity_from_input()
    character.move_and_slide()
    character.position = character.position.clamp(min_bound, max_bound)
    
func _calc_bounds_from_tilemap(ref_tilemap: TileMap) -> void:
    var map_limits: Rect2i = ref_tilemap.get_used_rect()
    var map_cell_size: Vector2i = ref_tilemap.tile_set.tile_size
    min_bound = Vector2(round(map_limits.position.x * map_cell_size.x * ref_tilemap.scale.x), round(map_limits.position.y * map_cell_size.y * ref_tilemap.scale.y))
    max_bound = Vector2(round(map_limits.end.x * map_cell_size.x * ref_tilemap.scale.x), round(map_limits.end.y * map_cell_size.y * ref_tilemap.scale.y))
    
func _get_velocity_from_input() -> Vector2:
    var velocity_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if velocity_dir.is_zero_approx():
        return Vector2.ZERO
    else:
        return velocity_dir.normalized() * speed;