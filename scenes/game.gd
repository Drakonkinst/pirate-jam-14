extends Node2D

class_name Game

signal on_quit_to_menu
signal restart_game

const MINUTE_TO_SECOND: float = 60.0

@export var level_data: LevelData
@export var player: Player
@export var player_spawn_point: Marker2D
@export var shader_control: ShaderControl
@export var text_particle_spawner: TextParticleSpawner

@onready var npc_spawner: NPCSpawner = $NPCSpawner
@onready var score_handler: ScoreHandler = $ScoreHandler
@onready var game_over_timer: Timer = $GameOverTimer
@onready var pause_control: PauseControl = $PauseControl
@onready var game_music: GameMusic = $GameMusic

@onready var game_over_menu: CanvasLayer = $GameOverMenu
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var hud: HUD = $HUD

func initialize():
	pause_control.unpause()
	game_music.initialize()
	npc_spawner.initialize(level_data)
	player.initialize(player_spawn_point.position)
	player.animation_control.set_shadow(level_data.is_day)
	hud.initialize(level_data.is_day)
	shader_control.set_time_of_day(ShaderControl.TimeOfDay.DAY if level_data.is_day else ShaderControl.TimeOfDay.NIGHT)
	if level_data.max_minutes > 0:
		#game_over_timer.start(3)
		game_over_timer.start(level_data.max_minutes * MINUTE_TO_SECOND)

func _on_npc_spawner_npc_mood_changed(who: NPC, from: Mood.Stage, to: Mood.Stage) -> void:
	if to == Mood.Stage.HAPPY:
		text_particle_spawner.spawn_increase_mood_text(who.global_position)
		if from == Mood.Stage.SAD:
			score_handler.increase_score(15)
		else:
			score_handler.increase_score(10)
	elif to == Mood.Stage.SAD:
		text_particle_spawner.spawn_decrease_mood_text(who.global_position)
		if from == Mood.Stage.HAPPY:
			score_handler.decrease_score(30)
		else:
			score_handler.decrease_score(15)

func _on_game_over_timer_timeout() -> void:
	pause_control.pause()
	pause_menu.hide()
	game_over_menu.show_game_over()
	hud.hide()

func _on_pause_control_paused() -> void:
	GlobalVariables.muffle_music()

func _on_pause_control_unpaused() -> void:
	GlobalVariables.unmuffle_music()

func _on_pause_menu_pressed_quit_to_menu() -> void:
	on_quit_to_menu.emit()

func _on_game_over_menu_restart_game() -> void:
	restart_game.emit()

func _on_game_over_menu_on_quit_to_menu() -> void:
	on_quit_to_menu.emit()
