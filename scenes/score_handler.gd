extends Node2D

class_name ScoreHandler

signal score_changed(value: int)

var score: int

func increase_score(value: int) -> void:
    set_score(score + value)

func decrease_score(value: int) -> void:
    set_score(score - value)

func set_score(value: int) -> void:
    if score != value:
        score = value
        score_changed.emit(score)

func get_score() -> int:
    return score
