extends AnimatedSprite2D

const ANIM := "default"

@export var chat_bubble: ChatBubble

# In a less spaghetti world this would only be a single spriteframes, switching animation based on state
# That is not this world

func _ready() -> void:
    animation = ANIM
    autoplay = ANIM
    play(ANIM)    

func _process(_delta: float) -> void:
    if chat_bubble.is_playing():
        hide()
    else:
        show()
    
