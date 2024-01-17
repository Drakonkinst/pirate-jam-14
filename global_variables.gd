extends Node

const PLAYER_GROUP = "player"
const VALID_THRESHOLD: float = 0.01

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