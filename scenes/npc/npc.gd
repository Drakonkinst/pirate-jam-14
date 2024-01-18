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
@export var detection_area: Area2D
@export var player_detection_range: float = 100.0

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
	animation_control.update_animations(velocity, behavior.should_lock_face(), behavior.get_facing_target())

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
			# Almost always will be distracted
			if behavior.get_time_wasted_multiplier() > 0.0:
				behavior.set_state(Behavior.State.INTERACT_CAT)
			mood.increase_mood(60)
		Personality.CatOpinion.LIKE:
			chat_bubble.show_emoji(ChatBubble.Emoji.HEART)
			# Lower chance to be distracted
			if randf() < 0.75 * behavior.get_time_wasted_multiplier():
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

# Prioritize state changes first, then ambient
func check_surroundings() -> void:
	if _handle_surroundings_state_changes():
		_handle_surroundings_ambient()

# Return true if no state was changed, and can proceed to ambient logic
func _handle_surroundings_state_changes() -> bool:
	var distance_to_player_sq := player.global_position.distance_squared_to(global_position)
	var can_see_player := distance_to_player_sq <= player_detection_range * player_detection_range
	var time_wasted_multiplier := behavior.get_time_wasted_multiplier()
	
	# If following cat, chance to stop and go back to walking
	if behavior.state == Behavior.State.INTERACT_CAT and randf() < 1.0 - time_wasted_multiplier:
		chat_bubble.show_emoji(ChatBubble.Emoji.CLOCK)
		behavior.set_state(Behavior.State.WALK_TO_EXIT)
		return false
	
	# TODO: Chance to attempt to start conversation if NPC is nearby (lower if late)
	# TODO: If empathetic, chance to gain or lose mood from nearby NPCs
	
	# If cat lover, chance to approach cat without prompting
	if behavior.state == Behavior.State.WALK_TO_EXIT and personality.cat_opinion == Personality.CatOpinion.LOVE and can_see_player and randf() < 0.3 * time_wasted_multiplier:
		# TODO Randomize between heart and alert?
		chat_bubble.show_emoji(ChatBubble.Emoji.HEART)
		behavior.set_state(Behavior.State.INTERACT_CAT)
		return false
	# If allergic, try to avoid cat
	if behavior.state != Behavior.State.AVOID and personality.cat_opinion == Personality.CatOpinion.ALLERGIC and can_see_player:
		mood.decrease_mood(20)
		chat_bubble.show_emoji(ChatBubble.Emoji.CROSS)
		behavior.start_avoiding(player)
		return false
	return true

func _handle_surroundings_ambient() -> void:
	# TODO: Ambient emoji if mood is rather positive
	# TODO: Ambient emoji if mood is rather negative
	# TODO: Rushed personality emoji if rushing
	pass

func despawn():
	queue_free()

func can_respond_to_noise() -> bool:
	return respond_noise_cooldown.is_stopped()

func _on_respond_noise_cooldown_timer_timeout() -> void:
	respond_noise_cooldown.stop()

func _on_behavior_has_pet_cat() -> void:
	mood.increase_mood(20)

func _on_update_behavior_timer_timeout() -> void:
	check_surroundings()
