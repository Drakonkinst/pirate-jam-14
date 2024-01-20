extends Sprite2D

@export var chat_bubble: ChatBubble

func _process(_delta: float) -> void:
    if chat_bubble.is_playing():
        hide()
    else:
        show()
    
