extends Node2D

class_name NoiseHandler

@export var noise_particle_scene: PackedScene
@export var player_noise_area: Area2D

func _on_player_made_noise(action: PlayerActions.Action, direction: float, origin: Vector2) -> void:
    for body in player_noise_area.get_overlapping_bodies():
        if body is NPC:
            var npc: NPC = body as NPC
            if not npc.can_respond_to_noise():
                continue
            match action:
                PlayerActions.Action.MEOW:
                    npc.was_meowed = true
                PlayerActions.Action.HISS:
                    npc.was_hissed = true
    _spawn_noise_particle(action, direction, origin)

func _spawn_noise_particle(action: PlayerActions.Action, angle: float, origin: Vector2):
    var noise_particle: NoiseParticle = noise_particle_scene.instantiate()
    noise_particle.action = action
    noise_particle.rotation = angle
    noise_particle.position = origin
    add_child(noise_particle)
