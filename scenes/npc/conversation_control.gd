extends Node2D

class_name ConversationControl

const MIN_DIST_THRESHOLD = 64.0

@export var chat_bubble: ChatBubble
@export var positive_emojis: Array[ChatBubble.Emoji]
@export var negative_emojis: Array[ChatBubble.Emoji]
@export var harasser_emojis: Array[ChatBubble.Emoji]

@onready var conversation_finish_timer: Timer = $ConversationFinishTimer
@onready var conversation_tick_timer: Timer = $ConversationTickTimer

signal on_finished_conversation(mood_change: int)

var conversation_target: NPC
var next_mood_change: float
var was_voluntary: bool
var was_forced: bool
var in_conversation: bool = false

func start(target: NPC, mood_change: int, conversation_time: float, voluntary: bool, forced: bool) -> void:
    conversation_target = target
    next_mood_change = mood_change
    was_voluntary = voluntary
    was_forced = forced
    in_conversation = true
    conversation_finish_timer.start(conversation_time)

func interrupt() -> void:
    if not in_conversation:
        return
    in_conversation = false

func get_target_pos() -> Vector2:
    if is_instance_valid(conversation_target):
        return conversation_target.global_position
    return global_position

func _on_conversation_finish_timer_timeout() -> void:
    conversation_finish_timer.stop()
    if not in_conversation:
        return
    in_conversation = false
    on_finished_conversation.emit(next_mood_change)

func _on_conversation_tick_timer_timeout() -> void:
    # Play an emoji based on outcome of the conversation
    if not in_conversation:
        return
    if get_target_pos().distance_squared_to(global_position) > MIN_DIST_THRESHOLD * MIN_DIST_THRESHOLD:
        return
    if was_forced:
        _play_random(harasser_emojis)
    elif next_mood_change < 0:
        _play_random(negative_emojis)
    else:
        _play_random(positive_emojis)
    

func _play_random(arr: Array[ChatBubble.Emoji]) -> void:
    var emoji := arr[randi() % arr.size()]
    chat_bubble.show_emoji(emoji)
