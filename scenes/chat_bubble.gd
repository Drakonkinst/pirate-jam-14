extends Node2D

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
    IDEA,
    LAUGH,
    MUSIC,
    QUESTION,
    SLEEP,
    SLEEPS,
    STAR,
    STARS,
    SWIRL,
    EMPTY
}

# Should be in the same order as the enum
@export var emojis: Array[Texture2D]

@onready var emoji_sprite: Sprite2D = $EmojiSprite
@onready var emoji_animator: AnimationPlayer = $EmojiSprite/AnimationPlayer
@onready var hide_timer: Timer = $HideTimer
    
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    emoji_sprite.hide()
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if not emoji_sprite.visible:
        #show_emoji(Emoji.HEART)
        show_emoji(randi() % emojis.size())
    
func show_emoji(emoji: Emoji) -> void:
    emoji_sprite.show()
    emoji_sprite.texture = emojis[emoji]
    emoji_animator.play(POP_IN_ANIMATION)
    hide_timer.start()
    
func _on_hide_timer_timeout() -> void:
    emoji_sprite.hide()
