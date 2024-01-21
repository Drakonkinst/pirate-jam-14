extends Label

@export var prefix: String = "Score: "

func set_score(score: int):
    text = prefix + str(score)

func _on_score_handler_score_changed(score: int) -> void:
    set_score(score)
