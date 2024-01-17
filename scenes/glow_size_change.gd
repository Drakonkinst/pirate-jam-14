extends Sprite2D

@export var noise: FastNoiseLite
@export var speed: float = 20.0
@export var max_bonus: float = 0.5
@onready var original_scale = scale
var time: float = 0.0

func _ready() -> void:
    time = randf_range(0.0, 1000.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    time += delta * speed
    scale = original_scale * (1.0 + noise.get_noise_1d(time) * max_bonus)