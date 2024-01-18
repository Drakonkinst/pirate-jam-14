extends Node2D

class_name Personality

enum Sociable {
	NORMAL,
	SOCIAL,
	ANTISOCIAL,
	RUSHED,
	HARASSER,
}

enum CatOpinion {
	LOVE,
	LIKE,
	DISLIKE,
	ALLERGIC
}

enum Modifier {
	EMPATHETIC
}

var sociable_type: Sociable
var cat_opinion: CatOpinion
var modifiers: Array[Modifier]

func set_sociable_type(value: Sociable) -> void:
	sociable_type = value

func set_cat_opinion(value: CatOpinion) -> void:
	cat_opinion = value

func set_modifiers(value: Array[Modifier]) -> void:
	modifiers = value

func add_modifier(value: Modifier) -> void:
	modifiers.append(value)
	
func has_modifier(value: Modifier) -> bool:
	return modifiers.has(value)

func get_sociable_type() -> Sociable:
	return sociable_type
	
func get_cat_opinion() -> CatOpinion:
	return cat_opinion
