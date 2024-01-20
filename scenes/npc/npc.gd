extends CharacterBody2D

class_name NPC

const AMBIENT_CHANCE := 0.1
const EMPATHY_MULTIPLIER := 0.2
const CONVERSATION_MOOD_MULTIPLIER := 1.0

signal mood_stage_changed(who: NPC, from: Mood.Stage, to: Mood.Stage)
signal lifetime_expired

@onready var personality: Personality = $Personality
@onready var mood: Mood = $Mood
@onready var move_control: MoveControl = $MoveControl
@onready var animation_control: AnimationControl = $AnimationControl
@onready var behavior: Behavior = $Behavior
@onready var chat_bubble: ChatBubble = $ChatBubble
@onready var conversation_control = $ConversationControl
@onready var player: Player = get_tree().get_nodes_in_group(GlobalVariables.PLAYER_GROUP)[0]

@onready var respond_noise_cooldown: Timer = $RespondNoiseCooldownTimer

@export var nav_control: NavigationControl
@export var detection_area: Area2D
@export var player_detection_range: float = 100.0

# Deferred signals
var was_meowed: bool = false
var was_hissed: bool = false
var despawned: bool = false

var speech: Dialogue

func initialize():
	# Set walking speed
	if personality.get_sociable_type() == Personality.Sociable.RUSHED:
		nav_control.randomize_base_speed(200, 50)
	else:
		nav_control.randomize_base_speed(100, 50)
	speech = chat_bubble.dialogue

func request_conversation(to: NPC, force: bool = false) -> bool:
	var response := to.respond_conversation(self)
	if response or force:
		have_conversation(to, response)
		return true
	on_conversation_declined()
	return false

func on_conversation_declined() -> void:
	if personality.sociable_type == Personality.Sociable.SOCIAL:
		mood.decrease_mood(10)

func respond_conversation(from: NPC) -> bool:
	var from_type := from.personality.sociable_type
	var time_wasted_multiplier := behavior.get_time_wasted_multiplier()
	
	match personality.sociable_type:
		Personality.Sociable.SOCIAL:
			return time_wasted_multiplier > 0.0 if from_type != Personality.Sociable.HARASSER else randf() < 0.5 * time_wasted_multiplier
		Personality.Sociable.NORMAL:
			return randf() < (0.75 if from_type != Personality.Sociable.HARASSER else 0.25) * time_wasted_multiplier
		Personality.Sociable.ANTISOCIAL:
			return false
		Personality.Sociable.RUSHED:
			return false
		Personality.Sociable.HARASSER:
			return randf() <(0.75 if from_type != Personality.Sociable.HARASSER else 0.25) * time_wasted_multiplier
	return false


func have_conversation(with: NPC, was_voluntary: bool) -> void:
	var self_mood_change: int = 0
	var other_mood_change: int = 0
	var self_mood = mood.get_mood()
	var other_mood = with.mood.get_mood()
	if not was_voluntary:
		self_mood_change = 20
		other_mood_change = -50
	elif self_mood * other_mood >= 0:
		# They are both the same sign, so affect both
		self_mood_change = int(other_mood * CONVERSATION_MOOD_MULTIPLIER)
		other_mood_change = int(self_mood * CONVERSATION_MOOD_MULTIPLIER)
	elif abs(self_mood) > abs(other_mood):
		other_mood_change = int(self_mood * CONVERSATION_MOOD_MULTIPLIER)
		self_mood_change = 1 if self_mood >= 0 else -1
	else:
		self_mood_change = int(other_mood * CONVERSATION_MOOD_MULTIPLIER)
		other_mood_change = 1 if other_mood >= 0 else -1
	
	var conversation_time: float = randf_range(7.0, 15.0)
	
	conversation_control.start(with, self_mood_change, conversation_time, true, not was_voluntary)
	with.conversation_control.start(self, other_mood_change, conversation_time, was_voluntary, false)
	on_start_conversation(true)
	# print("CONVERSATION STARTED ", self_mood_change, " vs ", other_mood_change)
	with.on_start_conversation(was_voluntary)

func on_start_conversation(was_voluntary: bool) -> void:
	match personality.sociable_type:
		Personality.Sociable.SOCIAL:
			mood.increase_mood(10)
		Personality.Sociable.ANTISOCIAL:
			if not was_voluntary:
				mood.decrease_mood(20)
		Personality.Sociable.RUSHED:
			if not was_voluntary:
				mood.decrease_mood(10)
	
func _on_conversation_control_on_finished_conversation(mood_change: int) -> void:
	mood.increase_mood(mood_change)
	# print("CONVERSATION FINISHED")
	behavior.set_state(Behavior.State.WALK_TO_EXIT)

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
			# Almost always will be distracted
			if behavior.get_time_wasted_multiplier() > 0.0 and behavior.state != Behavior.State.INTERACT_CAT:
				chat_bubble.do_greet_cat()
				behavior.set_state(Behavior.State.INTERACT_CAT)
				mood.increase_mood(60)
			else:
				mood.increase_mood(20)
		Personality.CatOpinion.LIKE:
			# Lower chance to be distracted
			if randf() < 0.75 * behavior.get_time_wasted_multiplier() and behavior.state != Behavior.State.INTERACT_CAT:
				chat_bubble.do_greet_cat()
				behavior.set_state(Behavior.State.INTERACT_CAT)
				mood.increase_mood(40)
			else:
				mood.increase_mood(10)
		Personality.CatOpinion.DISLIKE:
			chat_bubble.do_shoo_cat()
			mood.decrease_mood(10)
			behavior.start_avoiding(player)
		Personality.CatOpinion.ALLERGIC:
			chat_bubble.show_emoji(ChatBubble.Emoji.CROSS)
			mood.decrease_mood(20)
			behavior.start_avoiding(player)


func _receive_hiss() -> void:
	if conversation_control.in_conversation:
		if conversation_control.next_mood_change < 0 or randf() < 0.5:
			interrupt_conversation()
		return
	match personality.cat_opinion:
		Personality.CatOpinion.LOVE:
			chat_bubble.show_emoji(ChatBubble.Emoji.HEART_BROKEN)
			mood.decrease_mood(80)
			if behavior.state == Behavior.State.INTERACT_CAT:
				behavior.set_state(Behavior.State.WALK_TO_EXIT)
			else:
				behavior.start_avoiding(player)
		Personality.CatOpinion.LIKE:
			mood.decrease_mood(40)
			if behavior.state == Behavior.State.INTERACT_CAT:
				behavior.set_state(Behavior.State.WALK_TO_EXIT)
			else:
				behavior.start_avoiding(player)
		Personality.CatOpinion.DISLIKE:
			chat_bubble.do_shoo_cat()
			mood.decrease_mood(40)
			behavior.start_avoiding(player)
		Personality.CatOpinion.ALLERGIC:
			chat_bubble.show_emoji(ChatBubble.Emoji.CROSS)
			mood.decrease_mood(40)
			behavior.start_avoiding(player)

func interrupt_conversation():
	var other: NPC = conversation_control.conversation_target
	if conversation_control.in_conversation:
		# If they were having a good time, have a bad time
		if conversation_control.next_mood_change > 0:
			mood.decrease_mood(20)
		else:
			mood.increase_mood(10)
		if other.conversation_control.next_mood_change > 0:
			other.mood.decrease_mood(20)
		else:
			other.mood.increase_mood(10)
		
		chat_bubble.show_emoji(ChatBubble.Emoji.EXCLAMATION, true)
		other.chat_bubble.show_emoji(ChatBubble.Emoji.EXCLAMATION, true)
		behavior.set_state(Behavior.State.WALK_TO_EXIT)
		# print("CONVERSATION INTERRUPTED")
		
		# Interrupt
		other.conversation_control.interrupt()
		conversation_control.interrupt()
		behavior.start_conversation_timer.start()
		other.behavior.start_conversation_timer.start()

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
	if behavior.state == Behavior.State.WALK_TO_EXIT and can_see_player and randf() < 0.3:
		# Play ambient emote/message to show what the player thinks about the cat
		if personality.cat_opinion == Personality.CatOpinion.LOVE:
			chat_bubble.do_greet_cat()
			if randf() < time_wasted_multiplier:
				behavior.set_state(Behavior.State.INTERACT_CAT)
				return false
		elif personality.cat_opinion == Personality.CatOpinion.LIKE:
			chat_bubble.do_greet_cat()
		elif personality.cat_opinion == Personality.CatOpinion.DISLIKE:
			chat_bubble.do_shoo_cat()
	# If allergic, always try to avoid cat
	if behavior.state == Behavior.State.WALK_TO_EXIT and can_see_player and personality.cat_opinion == Personality.CatOpinion.ALLERGIC:
			mood.decrease_mood(5)
			chat_bubble.do_allergic_cat()
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
			if behavior.state == Behavior.State.WALK_TO_EXIT and behavior.start_conversation_timer.is_stopped() and not npc.conversation_control.in_conversation and npc.behavior.state == Behavior.State.WALK_TO_EXIT:
				if personality.sociable_type == Personality.Sociable.ANTISOCIAL or personality.sociable_type == Personality.Sociable.RUSHED:
					continue
				# Max 10% chance to attempt a conversation
				if randf() > (0.1 if personality.sociable_type != Personality.Sociable.SOCIAL else 0.2) * time_wasted_multiplier:
					continue
				# If harasser, high chance to try to force conversation on non-harassers
				var forced := personality.sociable_type == Personality.Sociable.HARASSER and npc.personality.sociable_type != Personality.Sociable.HARASSER
				var success := request_conversation(npc, forced and randf() < 0.75)
				if success:
					behavior.set_state(Behavior.State.CONVERSE)
					npc.behavior.set_state(Behavior.State.CONVERSE)
					behavior.start_conversation_timer.start()
					return false
				elif forced:
					npc.behavior.start_avoiding(self)
	
	# If empathetic, gain or lose mood from nearby NPCs
	if personality.has_modifier(Personality.Modifier.EMPATHETIC) and num_other_npcs > 0 and behavior.state == Behavior.State.WALK_TO_EXIT:
		var average_mood: float = clamp(empathy_mood_change * 1.0 / num_other_npcs, mood.MIN_MOOD, mood.MAX_MOOD)
		var mood_change: int = int(average_mood * EMPATHY_MULTIPLIER)
		# Visual hint they are empathetic
		# FACE_SAD should feel more impactful, so should not be used ambiently
		if mood_change > 10:
			chat_bubble.show_emoji(ChatBubble.Emoji.STARS)
		# elif mood_change < 10:
		# 	chat_bubble.show_emoji(ChatBubble.Emoji.FACE_SAD)
		print("EMPATHY ", mood_change)
		mood.increase_mood(mood_change)
	
	# If antisocial, lose mood if too many people nearby
	if personality.sociable_type == Personality.Sociable.ANTISOCIAL and num_other_npcs > 3:
		chat_bubble.show_emoji(ChatBubble.Emoji.ALERT)
		mood.decrease_mood(10)
	
	return true

func _handle_surroundings_ambient() -> void:
	if randf() < AMBIENT_CHANCE and behavior.state == Behavior.State.WALK_TO_EXIT:
		if personality.sociable_type == Personality.Sociable.RUSHED:
			chat_bubble.show_emoji(ChatBubble.Emoji.CLOCK)
		elif personality.sociable_type == Personality.Sociable.HARASSER:
			chat_bubble.show_emoji(ChatBubble.Emoji.CASH)

func despawn():
	if despawned:
		return false
	despawned = true
	# queue_free() only destroys the NPC on the next frame, so prevent
	# additional triggers with the despawned flag
	queue_free()
	return true

func can_respond_to_noise() -> bool:
	return respond_noise_cooldown.is_stopped()

func _on_respond_noise_cooldown_timer_timeout() -> void:
	respond_noise_cooldown.stop()

func _on_behavior_has_pet_cat() -> void:
	mood.increase_mood(20)

func _on_mood_mood_stage_changed(from: Mood.Stage, to: Mood.Stage) -> void:
	# if to == Mood.Stage.HAPPY:
	# 	chat_bubble.show_emoji(ChatBubble.Emoji.STAR, true)
	# elif to == Mood.Stage.SAD:
	# 	chat_bubble.show_emoji(ChatBubble.Emoji.FACE_ANGRY, true)
	mood_stage_changed.emit(self, from, to)


func _on_behavior_behavior_tick() -> void:
	check_surroundings()

# Despawn NPCs after a while in case they get stuck somewhere
# Band-aid fix because they do get stuck somewhere after a while
func _on_lifetime_timer_timeout() -> void:	
	lifetime_expired.emit()
	despawn()
