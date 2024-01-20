extends Node2D

class_name ShaderControl

const PLAYER_POS_PARAM := "player_pos"
const PLAYER_WORLD_POS_PARAM := "player_world_pos"
const SCREEN_WIDTH_PARAM := "screen_width"
const SCREEN_HEIGHT_PARAM := "screen_height"

enum TimeOfDay { DAY, NIGHT }

@export var player: Player
@export var camera: Camera2D
@export var time_of_day: TimeOfDay
@export_group("Shader")
@export var day_shader: CanvasItem
@export var night_shader: CanvasItem
@export_group("CanvasModulate")
@export var canvas_modulate: CanvasModulate
@export var day_tint: Color
@export var night_tint: Color

func _ready() -> void:
    set_time_of_day(time_of_day)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    # Since the game is resizable this must be updated every frame
    var screen_dimensions: Vector2 = get_viewport().get_visible_rect().size
    # Convert player position to UV position
    # Since we keep the height, use screen transform to make sure this still works even at smaller screen sizes
    var screen_coords: Vector2 = get_viewport().get_screen_transform().affine_inverse() * player.get_viewport_transform() * player.global_position
    var player_position_uv: Vector2 = screen_coords / screen_dimensions
    
    RenderingServer.global_shader_parameter_set(PLAYER_POS_PARAM, player_position_uv)
    RenderingServer.global_shader_parameter_set(PLAYER_WORLD_POS_PARAM, player.global_position)
    
    # There's probably a better way to do this, but I don't know it
    RenderingServer.global_shader_parameter_set(SCREEN_WIDTH_PARAM, screen_dimensions.x)
    RenderingServer.global_shader_parameter_set(SCREEN_HEIGHT_PARAM, screen_dimensions.y)

func set_time_of_day(time: TimeOfDay):
    if time == TimeOfDay.DAY:
        canvas_modulate.color = day_tint
        night_shader.hide()
        day_shader.show()
    else:
        canvas_modulate.color = night_tint
        day_shader.hide()
        night_shader.show()
    time_of_day = time