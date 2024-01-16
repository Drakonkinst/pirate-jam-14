extends Node2D

@export var level_data: LevelData
@export var player: Player
@export var player_spawn_point: Marker2D

@onready var npc_spawner: NPCSpawner = $NPCSpawner

func _ready() -> void:
	# Can possibly load something else first, then call initialize()
	initialize()
	
func initialize():
	npc_spawner.initialize(level_data)
	player.initialize(player_spawn_point.position)

