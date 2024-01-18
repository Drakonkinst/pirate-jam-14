extends CharacterBody2D

class_name NPC

@onready var personality: Personality = $Personality
@onready var mood: Mood = $Mood
@onready var move_control: MoveControl = $MoveControl
@onready var animation_control: AnimationControl = $AnimationControl
@onready var behavior: Behavior = $Behavior
@onready var chat_bubble: ChatBubble = $ChatBubble
@onready var player: Player = get_tree().get_nodes_in_group(GlobalVariables.PLAYER_GROUP)[0]

@onready var respond_noise_cooldown: Timer = $RespondNoiseCooldownTimer

@export var nav_control: NavigationControl

# Deferred signals
var was_meowed: bool = false
var was_hissed: bool = false

func initialize():
	# Set walking speed
	if personality.get_sociable_type() == Personality.Sociable.RUSHED:
		nav_control.randomize_base_speed(200, 50)
	else:
		nav_control.randomize_base_speed(100, 50)

func _physics_process(delta: float) -> void:
	_handle_deferred_signals()
	behavior.update(delta)
	move_control.update(self, delta)

func _process(_delta: float) -> void:
	animation_control.update_animations(velocity)

func _handle_deferred_signals() -> void:
	if can_respond_to_noise():
		if was_meowed:
			_receive_meow()
			respond_noise_cooldown.start()
		elif was_hissed:
			_receive_hiss()
			respond_noise_cooldown.start()
	was_meowed = false
	was_hissed = false

func _receive_meow() -> void:
	match personality.cat_opinion:
		Personality.CatOpinion.LOVE:
			chat_bubble.show_emoji(ChatBubble.Emoji.HEART)
			behavior.set_state(Behavior.State.INTERACT_CAT)
			mood.increase_mood(60)
		Personality.CatOpinion.LIKE:
			chat_bubble.show_emoji(ChatBubble.Emoji.HEART)
			behavior.set_state(Behavior.State.INTERACT_CAT)
			mood.increase_mood(40)
		Personality.CatOpinion.DISLIKE:
			chat_bubble.show_emoji(ChatBubble.Emoji.QUESTION)
			mood.decrease_mood(10)
			behavior.start_avoiding(player)
		Personality.CatOpinion.ALLERGIC:
			chat_bubble.show_emoji(ChatBubble.Emoji.CROSS)
			mood.decrease_mood(20)
			behavior.start_avoiding(player)


func _receive_hiss() -> void:
	match personality.cat_opinion:
		Personality.CatOpinion.LOVE:
			chat_bubble.show_emoji(ChatBubble.Emoji.HEART_BROKEN)
			mood.decrease_mood(40)
			if behavior.state == Behavior.State.INTERACT_CAT:
				behavior.set_state(Behavior.State.WALK_TO_EXIT)
			else:
				behavior.start_avoiding(player)
		Personality.CatOpinion.LIKE:
			mood.decrease_mood(20)
			if behavior.state == Behavior.State.INTERACT_CAT:
				behavior.set_state(Behavior.State.WALK_TO_EXIT)
			else:
				behavior.start_avoiding(player)
		Personality.CatOpinion.DISLIKE:
			chat_bubble.show_emoji(ChatBubble.Emoji.QUESTION)
			mood.decrease_mood(20)
			behavior.start_avoiding(player)
		Personality.CatOpinion.ALLERGIC:
			chat_bubble.show_emoji(ChatBubble.Emoji.CROSS)
			mood.decrease_mood(20)
			behavior.start_avoiding(player)
			
func despawn():
	queue_free()

func can_respond_to_noise() -> bool:
	return respond_noise_cooldown.is_stopped()

func _on_respond_noise_cooldown_timer_timeout() -> void:
	respond_noise_cooldown.stop()
