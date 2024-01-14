extends Node

const MOB_GROUP = "mobs"

@export var mob_scene: PackedScene
@export var mob_spawn_location: PathFollow2D
var score: int

func _new_game() -> void:
	score = 0
	$Player.start($PlayerStartPosition.position)
	$StartTimer.start()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	$Music.play()
	
	# Delete all mobs
	get_tree().call_group(MOB_GROUP, "queue_free")
	
func _game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_mob_timer_timeout() -> void:
	var mob: Node = mob_scene.instantiate()
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position
	
	# Set mob direction as perpendicular to path direction
	var direction := mob_spawn_location.rotation + PI / 2
	# Add some randomness
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# Set random velocity in given direction
	var velocity := Vector2(randf_range(150.0, 250.0,), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	# Spawn mob
	add_child(mob)
