extends Node2D

class_name NPCSpawner

# Instead of having properties here, most NPC spawning properties should be
# handled in level data.

enum Location { SCENE, LEFT, RIGHT }

@export var npc_scene: PackedScene

@export var npc_parent: Node2D
@export var area_scene: CollisionShape2D
@export var area_left: CollisionShape2D
@export var area_right: CollisionShape2D

var level_data: LevelData

func _process(_delta: float) -> void:
	_check_spawn_more_npcs()

func initialize(data: LevelData) -> void:
	set_level_data(data)
	_spawn_initial_npcs()

# Set level data in case we need to change it later
func set_level_data(data: LevelData):
	level_data = data

# Randomize and spawn an NPC based on level data
func spawn_random_npc(pos: Vector2) -> void:
	var spawned = npc_scene.instantiate()
	spawned.position = pos
	npc_parent.add_child(spawned)

	var npc = spawned as NPC
	npc.personality.set_sociable_type(level_data.generate_sociable())
	npc.personality.set_cat_opinion(level_data.generate_cat_opinion())
	npc.personality.set_modifiers(level_data.generate_modifiers())
	print("Spawned at ", pos)
	
# Spawn NPCs at random valid positions on navmesh
func _spawn_initial_npcs():
	# TODO: Make this number configurable
	var num_to_spawn: int = 10
	for i in num_to_spawn:
		_spawn_npc_from_location(Location.SCENE)

# Spawn NPC from left or right edge of map
func _spawn_npc_from_location(location: Location):
	spawn_random_npc(_get_random_point_in_area(_get_area_from_location(location)))
	
# Automatically spawn more
func _check_spawn_more_npcs():
	pass

# TODO: Add function to correct for valid positions
func _get_random_point_in_area(area: CollisionShape2D) -> Vector2:
	var dimensions: Vector2 = area.shape.extents
	var origin: Vector2 = area.global_position - dimensions
	print(dimensions, origin)
	var x: float = randf_range(origin.x, dimensions.x)
	var y: float = randf_range(origin.y, dimensions.y)
	return Vector2(x, y)

func _get_area_from_location(location: Location):
	match location:
		Location.LEFT:
			return area_left
		Location.RIGHT:
			return area_right
		_:
			return area_scene

