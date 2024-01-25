extends Node2D

class_name ScoreHandler

const SCORE_3_STARS = 200
const SCORE_2_STARS = 100
const SCORE_1_STARS = 50

static func calc_num_stars(score_value: int) -> int:
    if score_value >= SCORE_3_STARS:
        return 3
    if score_value >= SCORE_2_STARS:
        return 2
    if score_value >= SCORE_1_STARS:
        return 1
    return 0
    
signal score_changed(value: int)

var score: int

func increase_score(value: int) -> void:
    set_score(score + value)

func decrease_score(value: int) -> void:
    set_score(score - value)

func set_score(value: int) -> void:
    var next_score: int = clamp(value, 0, INF)
    if score != next_score:
        score = next_score
        score_changed.emit(score)

func get_num_stars() -> int:
    return ScoreHandler.calc_num_stars(score)

func get_score() -> int:
    return score
