extends CanvasLayer

class_name HUD

@export_group("External")
@export var time_remaining: Timer

@export_group("ScoreMeter")
@export var score_meter: ProgressBar
@export var filled_star_texture: CompressedTexture2D
@export var empty_star_texture: CompressedTexture2D
@export var star_1: Sprite2D
@export var star_2: Sprite2D
@export var star_3: Sprite2D
@export var speed: float = 15

@export_group("Timer")
@export var time_remaining_bar: TextureProgressBar
@export var day_color: Color
@export var night_color: Color
@export var center_sprite: Sprite2D

var target_score: float
var displayed_score: float
var prev_num_stars: int = 0

@onready var time_remaining_container: Node = $TimeRemainingUIContainer

func _ready() -> void:
    time_remaining_container.hide()
    target_score = 0
    set_displayed_score(0)

func initialize(is_day: bool) -> void:
    if is_day:
        time_remaining_bar.tint_under = night_color
        time_remaining_bar.tint_progress = day_color
        center_sprite.modulate = night_color
    else:
        time_remaining_bar.tint_under = day_color
        time_remaining_bar.tint_progress = night_color
        center_sprite.modulate = day_color
        
func _process(delta: float) -> void:
    if not time_remaining.is_stopped():
        time_remaining_container.show()
        var progress := time_remaining.time_left / time_remaining.wait_time
        time_remaining_bar.value = time_remaining_bar.min_value + (time_remaining_bar.max_value - time_remaining_bar.min_value) * progress
        
    if displayed_score < target_score:
        set_displayed_score(min(displayed_score + speed * delta, target_score))
    elif displayed_score > target_score:
        set_displayed_score(max(displayed_score - speed * delta, target_score))

func set_displayed_score(score: float):
    displayed_score = score
    score_meter.value = (displayed_score * 1.0 / ScoreHandler.SCORE_3_STARS) * (score_meter.max_value - score_meter.min_value) + score_meter.min_value
    update_stars(int(displayed_score))

func update_stars(score: int):
    var num_stars: int = ScoreHandler.calc_num_stars(score)
    if prev_num_stars != num_stars:
        # TODO Can play a sound or something
        prev_num_stars = num_stars
    star_1.texture = filled_star_texture if num_stars >= 1 else empty_star_texture
    star_2.texture = filled_star_texture if num_stars >= 2 else empty_star_texture
    star_3.texture = filled_star_texture if num_stars >= 3 else empty_star_texture
    
func _on_score_handler_score_changed(value: int) -> void:
    target_score = value
