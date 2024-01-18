extends Node2D

class_name ChatBubble

const POP_IN_ANIMATION = "pop_in"
const POP_OUT_ANIMATION = "pop_out"

enum Emoji {
    ALERT,
    ANGER,
    BARS,
    CASH,
    CIRCLE,
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

@onready var emoji_sprite: Sprite2D = $EmojiSprite
@onready var emoji_animator: AnimationPlayer = $EmojiSprite/AnimationPlayer
@onready var hide_timer: Timer = $HideTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    emoji_sprite.hide()

func show_emoji(emoji: Emoji) -> bool:
    # Prevent if on cooldown
    if not hide_timer.is_stopped():
        return false
    emoji_sprite.show()
    emoji_sprite.texture = emojis[emoji]
    emoji_animator.play(POP_IN_ANIMATION)
    hide_timer.start()
    return true
    
func _on_hide_timer_timeout() -> void:
    emoji_sprite.hide()
    hide_timer.stop()
