extends Node2D

class_name Mood

enum Stage {
	SAD,
	NORMAL,
	HAPPY,
}

const MIN_MOOD: int = -100
const MAX_MOOD: int = 100

signal mood_stage_changed(from: Stage, to: Stage)

@export var weather_mood_sprite: Sprite2D
@export var rainy: CompressedTexture2D
@export var cloudy: CompressedTexture2D
@export var normal: CompressedTexture2D
@export var sunny: CompressedTexture2D

@onready var mood_change_cooldown: Timer = $StageChangeCooldown
var mood: int = 0
var mood_stage: Stage = Stage.NORMAL

func increase_mood(value: int) -> void:
	set_mood(mood + value)
	
func decrease_mood(value: int) -> void:
	set_mood(mood - value)
		
func set_mood(value: int) -> void:
	var next_mood: int = clamp(value, MIN_MOOD, MAX_MOOD)
	if mood_stage != Stage.SAD and next_mood <= MIN_MOOD:
		next_mood = MIN_MOOD
		mood_stage_changed.emit(mood_stage, Stage.SAD)
		_set_mood_stage(Stage.SAD)
	elif mood_stage != Stage.HAPPY and next_mood >= MAX_MOOD:
		next_mood = MAX_MOOD
		mood_stage_changed.emit(mood_stage, Stage.HAPPY)
		_set_mood_stage(Stage.HAPPY)
	# Mood change reactions should be handled at a higher level
	#if next_mood != mood:
		# mood_changed.emit()
	mood = next_mood
	update_sprite()

func update_sprite() -> void:
	weather_mood_sprite.texture = get_sprite()

func get_sprite() -> CompressedTexture2D:
	if mood_stage == Stage.SAD:
		return rainy
	elif mood_stage == Stage.HAPPY:
		return sunny
	elif mood < 0:
		return cloudy
	return normal

func get_mood() -> int:
	return mood

func get_mood_stage() -> Stage:
	return mood_stage

func _set_mood_stage(stage: Stage):
	if mood_change_cooldown.is_stopped() and stage != mood_stage:
		mood_stage = stage
		mood_change_cooldown.start()

func _on_stage_change_cooldown_timeout() -> void:
	mood_change_cooldown.stop()
