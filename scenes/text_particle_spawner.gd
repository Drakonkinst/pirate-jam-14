extends Node2D

class_name TextParticleSpawner

@export var text_particle_scene: PackedScene
@export var offset: Vector2
@export var increase_mood_color: Color
@export var decrease_mood_color: Color

func spawn_increase_mood_text(pos: Vector2):
    spawn_text_particle(pos, "+ Mood", increase_mood_color)

func spawn_decrease_mood_text(pos: Vector2):
    spawn_text_particle(pos, "- Mood", decrease_mood_color)

func spawn_text_particle(pos: Vector2, text: String, color: Color):
    var node: TextParticle = text_particle_scene.instantiate()
    node.global_position = pos + offset
    add_child(node)
    node.set_attributes(text, color)