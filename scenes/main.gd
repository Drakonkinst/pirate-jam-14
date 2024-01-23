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
        menu.queue_free()
    game = game_scene.instantiate()
    game.level_data = _fetch_level_data()
    game.on_quit_to_menu.connect(_on_game_on_quit_to_menu)
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
        game.queue_free()
    init_main_menu()
