extends Node2D

const PLAYER_POS_PARAM := "player_pos"
const SCREEN_WIDTH_PARAM := "screen_width"
const SCREEN_HEIGHT_PARAM := "screen_height"

@export var player: Player
@export var camera: Camera2D
@export var world_shader: CanvasItem

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    # Since the game is resizable this must be updated every frame
    var screen_dimensions: Vector2 = get_viewport().get_visible_rect().size
    # Convert player position to UV position
    # Since we keep the height, use screen transform to make sure this still works even at smaller screen sizes
    var screen_coords: Vector2 = get_viewport().get_screen_transform().affine_inverse() * player.get_viewport_transform() * player.global_position
    var player_position_uv: Vector2 = screen_coords / screen_dimensions
    world_shader.material.set_shader_parameter(PLAYER_POS_PARAM, player_position_uv)
    
    # There's probably a better way to do this, but I don't know it
    world_shader.material.set_shader_parameter(SCREEN_WIDTH_PARAM, screen_dimensions.x)
    world_shader.material.set_shader_parameter(SCREEN_HEIGHT_PARAM, screen_dimensions.y)
