extends CharacterBody2D

class_name Player

signal made_noise(action: PlayerActions.Action, direction: float, origin: Vector2)

@export var ref_tilemap: TileMap # Optional tilemap to determine player bounds

@onready var animation_control: PlayerAnimationControl = $PlayerAnimationControl
@onready var move_control: PlayerMoveControl = $PlayerMoveControl
@onready var chat_bubble: ChatBubble = $ChatBubble
@onready var hiss_audio: AudioStreamPlayer2D = $HissAudio
@onready var meow_audio: AudioStreamPlayer2D = $MeowAudio
@onready var purr_audio: AudioStreamPlayer2D = $PurrAudio

func _ready() -> void:
	hide()
	move_control.initialize(ref_tilemap)

func _process(_delta: float) -> void:
	animation_control.update_animations(velocity)
	
func _physics_process(delta: float) -> void:
	move_control.update(self, delta)

func initialize(start_pos: Vector2) -> void:
	position = start_pos
	show()

func pet() -> bool:
	if not purr_audio.playing:
		purr_audio.play()
	return chat_bubble.show_emoji(ChatBubble.Emoji.HEART)

func _on_player_actions_made_noise(action: PlayerActions.Action, direction: float, origin: Vector2) -> void:
	if action == PlayerActions.Action.HISS:
		hiss_audio.play()
		purr_audio.stop()
	elif action == PlayerActions.Action.MEOW:
		meow_audio.play()
		purr_audio.stop()
	made_noise.emit(action, direction, origin)
