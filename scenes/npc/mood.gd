extends Node2D

class_name Mood

enum Stage {
	SAD,
	NORMAL,
	HAPPY,
}

const MIN_MOOD: int = -100
const MAX_MOOD: int = 100

signal mood_changed
signal mood_stage_changed

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
		_set_mood_stage(Stage.SAD)
	elif mood_stage != Stage.HAPPY and next_mood >= MAX_MOOD:
		next_mood = MAX_MOOD
		_set_mood_stage(Stage.HAPPY)
	if next_mood != mood:
		mood_changed.emit()
	mood = next_mood

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
