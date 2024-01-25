extends Node2D

class_name ChatBubble

const POP_IN_ANIMATION = "pop_in"
const POP_OUT_ANIMATION = "pop_out"
const DIALOGUE_CHANCE = 0.2

enum Emoji {
    ALERT,
    ANGER,
    BARS,
    CASH,
    CIRCLE,
    CLOCK,
    CLOUD,
    CROSS,
    DOTS1,
    DOTS2,
    DOTS3,
    DROP,
    DROPS,
    EXCLAMATION,
    EXCLAMATIONS,
    FACE_ANGRY,
    FACE_HAPPY,
    FACE_SAD,
    HEART,
    HEART_BROKEN,
    HEARTS,
    IDEA,
    LAUGH,
    MUSIC,
    QUESTION,
    SLEEP,
    SLEEPS,
    STAR,
    STARS,
    SWIRL,
    EMPTY,
}

# Should be in the same order as the enum
@export var emojis: Array[Texture2D]
@export var dialogue: Dialogue

@onready var emoji_sprite: Sprite2D = $EmojiSprite
@onready var emoji_animator: AnimationPlayer = $EmojiSprite/AnimationPlayer
@onready var hide_timer: Timer = $HideTimer
@onready var dialogue_control: DialogueControl = $DialogueControl

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    emoji_sprite.hide()

# Main 2 methods

func show_emoji(emoji: Emoji, force: bool = false) -> bool:
    # Prevent if on cooldown
    if not _can_play() and not force:
        return false
    emoji_sprite.show()
    emoji_sprite.texture = emojis[emoji]
    emoji_animator.play(POP_IN_ANIMATION)
    hide_timer.start()
    return true

func show_dialogue(line: String) -> bool:
    if not _can_play():
        return false
    dialogue_control.play_text(line)
    hide_timer.start()
    return true

# Public helpers for certain actions

func show_dialogue_from_category(category: Array[String]) -> void:
    show_dialogue(dialogue.generate_line(category))

func do_greet_cat() -> void:
    if _can_use_dialogue() and randf() < DIALOGUE_CHANCE:
        show_dialogue_from_category(dialogue.greet_cat)
    else:
        show_emoji(Emoji.HEART)

func do_shoo_cat() -> void:
    if _can_use_dialogue() and randf() < DIALOGUE_CHANCE:
        show_dialogue_from_category(dialogue.shoo_cat)
    else:
        show_emoji(Emoji.QUESTION)

func do_allergic_cat() -> void:
    if _can_use_dialogue() and randf() < DIALOGUE_CHANCE:
        show_dialogue_from_category(dialogue.allergic_cat)
    else:
        show_emoji(ChatBubble.Emoji.CROSS)

func do_start_convo() -> void:
    if _can_use_dialogue() and randf() < DIALOGUE_CHANCE:
        show_dialogue_from_category(dialogue.start_convo)
        
func do_convo_line() -> bool:
    if _can_use_dialogue() and randf() < DIALOGUE_CHANCE:
        show_dialogue_from_category(dialogue.accept_convo)
        return true
    return false
    
func do_running_late() -> void:
    if _can_use_dialogue() and randf() < DIALOGUE_CHANCE:
        show_dialogue_from_category(dialogue.decline_convo)
    else:
        show_emoji(ChatBubble.Emoji.CLOCK)

func is_playing():
    return not _can_play()    

# Helpers

func _can_use_dialogue() -> bool:
    return true

func _can_play() -> bool:
    return hide_timer.is_stopped() and not dialogue_control.is_showing_text()
    
func _on_hide_timer_timeout() -> void:
    emoji_sprite.hide()
    hide_timer.stop()
