extends Node2D

@export var level_data: LevelData
@export var player: Player
@export var player_spawn_point: Marker2D
@export var shader_control: ShaderControl

@onready var npc_spawner: NPCSpawner = $NPCSpawner
@export var text_particle_spawner: TextParticleSpawner

func _ready() -> void:
	# Can possibly load something else first, then call initialize()
	initialize()
	
func initialize():
	npc_spawner.initialize(level_data)
	player.initialize(player_spawn_point.position)
	player.animation_control.set_shadow(level_data.is_day)
	shader_control.set_time_of_day(ShaderControl.TimeOfDay.DAY if level_data.is_day else ShaderControl.TimeOfDay.NIGHT)

func _on_npc_spawner_npc_mood_changed(who: NPC, _from: Mood.Stage, to: Mood.Stage) -> void:
	print("SPAWNED")
	if to == Mood.Stage.HAPPY:
		text_particle_spawner.spawn_increase_mood_text(who.global_position)
	elif to == Mood.Stage.SAD:
		text_particle_spawner.spawn_decrease_mood_text(who.global_position)
