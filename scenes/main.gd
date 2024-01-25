extends Node

@export var game_scene: PackedScene
@export var menus_scene: PackedScene
@export var level_data: Array[LevelData]

var menu: Menus
var game: Game
func _ready() -> void:
    init_main_menu()


func start_new_game() -> void:
    if menu != null:
        remove_child(menu)
        menu = null
    game = game_scene.instantiate()
    game.level_data = _fetch_level_data()
    game.on_quit_to_menu.connect(_on_game_on_quit_to_menu)
    game.restart_game.connect(_on_game_on_restart_level)
    add_child(game)
    game.initialize()

func init_main_menu() -> void:
    menu = menus_scene.instantiate()
    menu.on_game_started.connect(start_new_game)
    add_child(menu)

func _fetch_level_data() -> LevelData:
    var level: LevelData = level_data[GlobalVariables.next_level_index]
    level.initialize()
    return level

func _on_game_on_quit_to_menu() -> void:
    if game != null:
        remove_child(game)
        game = null
    init_main_menu()

# https://forum.godotengine.org/t/discussion-of-best-practices-regarding-queue-free/5159
func _on_game_on_restart_level() -> void:
    if game != null:
        remove_child(game)
        game = null
    start_new_game()