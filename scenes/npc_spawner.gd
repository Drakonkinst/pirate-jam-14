extends Node2D

class_name NPCSpawner

# Instead of having properties here, most NPC spawning properties should be
# handled in level data.

enum Location { SCENE, LEFT, RIGHT }

signal npc_mood_changed(who: NPC, from: Mood.Stage, to: Mood.Stage)

@export var npc_scene: PackedScene

@export var npc_parent: Node2D
@export var area_scene: CollisionShape2D
@export var area_left: CollisionShape2D
@export var area_right: CollisionShape2D

var nav_map: RID
var level_data: LevelData
var npc_count: int = 0
var has_spawned_initial: bool = false

func _ready() -> void:
	nav_map = get_world_2d().navigation_map

func _process(_delta: float) -> void:
	if has_spawned_initial:
		_check_spawn_more_npcs()

func initialize(data: LevelData) -> void:
	set_level_data(data)
	# For some reason, the map isn't initialized on the first frame
	# So wait exactly one frame before spawning or else everyone spawns at (0, 0)
	await get_tree().create_timer(0).timeout
	_spawn_initial_npcs()

# Set level data in case we need to change it later
func set_level_data(data: LevelData):
	level_data = data

# Randomize and spawn an NPC based on level data
func spawn_random_npc(pos: Vector2, location: Location) -> void:
	var spawned = npc_scene.instantiate()
	spawned.position = pos
	npc_parent.add_child(spawned)

	var npc = spawned as NPC
	var personality: Personality = npc.personality
	personality.set_sociable_type(level_data.generate_sociable())
	personality.set_cat_opinion(level_data.generate_cat_opinion())
	personality.set_modifiers(level_data.generate_modifiers())

	var behavior: Behavior = npc.behavior
	match location:
		Location.LEFT:
			behavior.set_moving_east(true)
		Location.RIGHT:
			behavior.set_moving_east(false)
		_:
			behavior.set_moving_east(randf() < 0.5)
		
	# Set other stats based on personality
	var starting_mood = randi_range(level_data.min_starting_mood, level_data.max_starting_mood)
	npc.mood.set_mood(starting_mood)
	npc.animation_control.set_shadow(level_data.is_day)
	#print("INITIAL MOOD = ", npc.mood.get_mood(), " ", level_data.min_starting_mood, " ", level_data.max_starting_mood)
	npc.initialize()
	npc_count += 1
	
	
	print("NPC spawned at ", pos, " with sociable = ", Personality.Sociable.keys()[personality.get_sociable_type()], ", cat opinion = ", Personality.CatOpinion.keys()[personality.get_cat_opinion()], ", modifiers = ", personality.has_modifier(Personality.Modifier.EMPATHETIC), ", moving_east = ", behavior.is_moving_east())
	#print("NPC spawned (", npc_count, ") (", get_tree().get_nodes_in_group("mobs").size(), ")")
	
	# Connect signals
	npc.lifetime_expired.connect(_on_npc_lifetime_expired)
	npc.mood_stage_changed.connect(_on_npc_mood_stage_changed)
	
# Spawn NPCs at random valid positions on navmesh
func _spawn_initial_npcs():
	for i in level_data.npc_quota:
		_spawn_npc_from_location(Location.SCENE)
	# Should start tracking score after this point, since some levels may have NPCs start already with ruined mood?
	has_spawned_initial = true

# Spawn NPC from left or right edge of map
func _spawn_npc_from_location(location: Location, must_be_on_navmesh := true):
	var spawn_pos: Vector2 = _get_random_point_in_area(_get_area_from_location(location))
	if must_be_on_navmesh:
		spawn_pos = GlobalVariables.get_nearest_point_on_map(nav_map, spawn_pos)
	spawn_random_npc(spawn_pos, location)
	
# Automatically spawn more
func _check_spawn_more_npcs():
	while npc_count < level_data.npc_quota:
		var location: Location = Location.LEFT if randf() < 0.5 else Location.RIGHT
		_spawn_npc_from_location(location, false)

func _get_random_point_in_area(area: CollisionShape2D) -> Vector2:
	var extents: Vector2 = area.shape.extents
	var origin: Vector2 = area.global_position
	var x: float = randf_range(origin.x - extents.x, origin.x + extents.x)
	var y: float = randf_range(origin.y - extents.y, origin.y + extents.y)
	return Vector2(x, y)

func _get_area_from_location(location: Location):
	match location:
		Location.LEFT:
			return area_left
		Location.RIGHT:
			return area_right
		_:
			return area_scene

func _on_despawn_handler_on_npc_despawned() -> void:
	npc_count -= 1

func _on_npc_lifetime_expired() -> void:
	npc_count -= 1

func _on_npc_mood_stage_changed(who: NPC, from: Mood.Stage, to: Mood.Stage) -> void:
	npc_mood_changed.emit(who, from, to)
