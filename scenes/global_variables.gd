extends Node

const PLAYER_GROUP = "player"
const VALID_THRESHOLD: float = 0.01
const CONFIG_PATH = "user://settings.cfg"

var next_level_index: int = 0
var config := ConfigFile.new()
var music := AudioServer.get_bus_index("Music")
var effects := AudioServer.get_bus_index("Effects")

func _ready() -> void:
    _load_config()

func _load_config() -> void:
    var err := config.load(CONFIG_PATH)
    if err == OK:
        if config.has_section_key("audio", "music"):
            set_music_volume(config.get_value("audio", "music"), false)
        else:
            set_music_volume(1.0, false)
        if config.has_section_key("audio", "effects"):
            set_effects_volume(config.get_value("audio", "effects"), false)
        else:
            set_effects_volume(1.0, false)
        config.save(CONFIG_PATH)

func set_music_volume(value: float, save: bool = true) -> void:
    AudioServer.set_bus_volume_db(music, linear_to_db(value))
    if save:
        config.set_value("audio", "music", value)
        config.save(CONFIG_PATH)

func set_effects_volume(value: float, save: bool = true) -> void:
    AudioServer.set_bus_volume_db(effects, linear_to_db(value))
    if save:
        config.set_value("audio", "effects", value)
        config.save(CONFIG_PATH)

func get_music_volume() -> float:
    return db_to_linear(AudioServer.get_bus_volume_db(music))

func get_effects_volume() -> float:
    return db_to_linear(AudioServer.get_bus_volume_db(effects))

func get_nearest_point_on_map(nav_map: RID, target_point: Vector2, min_distance_from_edge: float = 4.0) -> Vector2:
    var closest_point: Vector2 = NavigationServer2D.map_get_closest_point(nav_map, target_point)
    var delta := closest_point - target_point
    if delta.length_squared() > VALID_THRESHOLD * VALID_THRESHOLD:
        closest_point += delta.normalized() * min_distance_from_edge
    return closest_point

# There doesn't seem to a function to check if a point is on a navmesh nor
# to select a random point on a navmesh 
func is_valid_navmesh_position(nav_map: RID, target_point: Vector2) -> bool:
    var closest_point: Vector2 = NavigationServer2D.map_get_closest_point(nav_map, target_point)
    var delta := closest_point - target_point
    return delta.length_squared() <= VALID_THRESHOLD * VALID_THRESHOLD