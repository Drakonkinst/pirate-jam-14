extends MarginContainer

class_name Menus

@onready var main_menu: MainMenu = $MainMenu
@onready var options_menu: OptionsMenu = $OptionsMenu
@onready var credits_menu: CreditsMenu = $CreditsMenu
@onready var level_select_menu: LevelSelectMenu = $LevelSelectMenu

signal on_game_started

func _ready() -> void:
    options_menu.hide()
    credits_menu.hide()
    level_select_menu.hide()

func _on_main_menu_pressed_game_start() -> void:
    main_menu.hide()
    level_select_menu.show()

func _on_main_menu_pressed_options() -> void:
    options_menu.show()

func _on_main_menu_pressed_credits() -> void:
    credits_menu.show()

func _on_options_menu_pressed_back() -> void:
    main_menu.on_enable()

func _on_credits_menu_pressed_back() -> void:
    main_menu.on_enable()

func _on_level_select_menu_pressed_back() -> void:
    level_select_menu.hide()
    main_menu.show()

func _on_level_select_menu_level_selected() -> void:
    on_game_started.emit()
