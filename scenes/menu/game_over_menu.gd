extends CanvasLayer

signal restart_game
signal on_quit_to_menu

const SCORE_PREFIX = "Score: "

@export_group("External")
@export var score_handler: ScoreHandler

@export_group("Internal")
@export var filled_star_texture: CompressedTexture2D
@export var empty_star_texture: CompressedTexture2D
@export var score_text: Label
@export var star_1: TextureRect
@export var star_2: TextureRect 
@export var star_3: TextureRect 

func _ready() -> void:
    hide()
    
func show_game_over() -> void:
    var score: int = score_handler.get_score()
    score_text.text = SCORE_PREFIX + str(score)
    fill_stars(score_handler.get_num_stars())
    show()



func fill_stars(count: int) -> void:
    star_1.texture = filled_star_texture if count >= 1 else empty_star_texture
    star_2.texture = filled_star_texture if count >= 2 else empty_star_texture
    star_3.texture = filled_star_texture if count >= 3 else empty_star_texture
    
func _on_return_to_menu_pressed() -> void:
    on_quit_to_menu.emit()

func _on_restart_level_pressed() -> void:
    restart_game.emit()
