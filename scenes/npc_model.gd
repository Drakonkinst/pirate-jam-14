extends AnimatedSprite2D

class_name NPCModel

@export var models: Array[SpriteFrames]
var model_index: int

func _ready() -> void:
    # Choose a random model
    model_index = randi() % models.size()
    _update_model()
    
func set_model(index: int) -> void:
    model_index = index
    _update_model()

func _update_model() -> void:
    sprite_frames = models[model_index]


