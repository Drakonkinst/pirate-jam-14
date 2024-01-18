extends Node2D

class_name NoiseParticle

@export var meow_sprite: SpriteFrames
@export var hiss_sprite: SpriteFrames
@export var meow_color: Color
@export var hiss_color: Color
@export var forward_speed: float = 60.0
@export var start_forward_distance: float = 40.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var action: PlayerActions.Action
var direction: Vector2

# Set action and position before calling add_child()
func _ready() -> void:
    sprite.sprite_frames = meow_sprite if action == PlayerActions.Action.MEOW else hiss_sprite
    sprite.modulate = meow_color if action == PlayerActions.Action.MEOW else hiss_color
    sprite.position += start_forward_distance * Vector2.RIGHT
    sprite.play()

func _physics_process(delta: float) -> void:
    # Local position is already rotated, so right = forwards in this case
    sprite.position += forward_speed * Vector2.RIGHT * delta

# Destroy self when finishing animation
# It keeps looping instead of calling finished() for some reason so we use this function instead
# func _on_animated_sprite_2d_animation_finished() -> void:
func _on_animated_sprite_2d_animation_looped() -> void:
    queue_free()
