extends CharacterBody2D

class_name NPC

const AMBIENT_CHANCE := 0.1
const EMPATHY_MULTIPLIER := 0.1

signal mood_stage_changed(from: Mood.Stage, to: Mood.Stage)

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
			if behavior.get_time_wasted_multiplier() > 0.0 and behavior.state != Behavior.State.INTERACT_CAT:
				behavior.set_state(Behavior.State.INTERACT_CAT)
				mood.increase_mood(60)
			else:
				mood.increase_mood(20)
		Personality.CatOpinion.LIKE:
			chat_bubble.show_emoji(ChatBubble.Emoji.HEART)
			# Lower chance to be distracted
			if randf() < 0.75 * behavior.get_time_wasted_multiplier() and behavior.state != Behavior.State.INTERACT_CAT:
				behavior.set_state(Behavior.State.INTERACT_CAT)
				mood.increase_mood(40)
			else:
				mood.increase_mood(10)
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
# Runs every ~2 seconds
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
	# If cat lover, chance to approach cat without prompting
	if behavior.state == Behavior.State.WALK_TO_EXIT and personality.cat_opinion == Personality.CatOpinion.LOVE and can_see_player and randf() < 0.3 * time_wasted_multiplier:
		chat_bubble.show_emoji(ChatBubble.Emoji.HEART)
		behavior.set_state(Behavior.State.INTERACT_CAT)
		return false
	# If allergic, try to avoid cat
	if behavior.state != Behavior.State.AVOID and personality.cat_opinion == Personality.CatOpinion.ALLERGIC and can_see_player:
		mood.decrease_mood(20)
		chat_bubble.show_emoji(ChatBubble.Emoji.CROSS)
		behavior.start_avoiding(player)
		return false
	
	var nearby_npcs: Array[Node2D] = detection_area.get_overlapping_bodies()
	var empathy_mood_change: int = 0
	var num_other_npcs: int = 0
	for item: Node2D in nearby_npcs:
		if item is NPC and item != self:
			num_other_npcs += 1
			var npc: NPC = item as NPC
			empathy_mood_change += npc.mood.get_mood()
			if behavior.start_conversation_timer.is_stopped():
				# TODO: Chance to attempt to start conversation if NPC is nearby (lower if late)
				# If harasser, only talk to non-harassers
				# If anti-social or rushed, never stop
				# Do a handshake to see if the other NPC wants to talk, with a harasser chance to force the conversation
				# Social loses mood if the other npc doesn't want to talk
				# If sociable, higher chance (lower if late); antisocial and rushed never respond unless forced to (and lose mood)
				pass
	
	# If empathetic, gain or lose mood from nearby NPCs
	if personality.has_modifier(Personality.Modifier.EMPATHETIC):
		var average_mood: float = clamp(empathy_mood_change * 1.0 / num_other_npcs, mood.MIN_MOOD, mood.MAX_MOOD)
		var mood_change: int = int(average_mood * EMPATHY_MULTIPLIER)
		if mood_change > 10:
			chat_bubble.show_emoji(ChatBubble.Emoji.STARS)
		elif mood_change < 10:
			chat_bubble.show_emoji(ChatBubble.Emoji.FACE_SAD)
		mood.increase_mood(mood_change)
	
	# If antisocial, lose mood if too many people nearby
	if personality.sociable_type == Personality.Sociable.ANTISOCIAL and num_other_npcs > 3:
		chat_bubble.show_emoji(ChatBubble.Emoji.ALERT)
		mood.decrease_mood(10)
	
	return true

func _handle_surroundings_ambient() -> void:
	if randf() < AMBIENT_CHANCE and behavior.state == Behavior.State.WALK_TO_EXIT:
		if mood.get_mood() >= 100:
			chat_bubble.show_emoji(ChatBubble.Emoji.STAR)
		if mood.get_mood() >= 50:
			chat_bubble.show_emoji(ChatBubble.Emoji.FACE_HAPPY)
		elif mood.get_mood() <= -100:
			chat_bubble.show_emoji(ChatBubble.Emoji.FACE_ANGRY)
		elif mood.get_mood() <= -50:
			chat_bubble.show_emoji(ChatBubble.Emoji.FACE_SAD)
		elif personality.sociable_type == Personality.Sociable.RUSHED:
			chat_bubble.show_emoji(ChatBubble.Emoji.CLOCK)

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

func _on_mood_mood_stage_changed(from: Mood.Stage, to: Mood.Stage) -> void:
	if to == Mood.Stage.HAPPY:
		print("Happy!")
	elif to == Mood.Stage.SAD:
		print("Sad :(")
	# TODO: Change mood visuals
	mood_stage_changed.emit(from, to)
