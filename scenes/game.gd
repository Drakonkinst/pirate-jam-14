extends Node2D

@export var level_data: LevelData

@onready var npc_spawner: NPCSpawner = $NPCSpawner

func _ready() -> void:
	npc_spawner.initialize(level_data)
