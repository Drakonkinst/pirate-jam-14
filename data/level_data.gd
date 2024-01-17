extends Resource

# This script does a lot of the heavy lifting to turn user-friendly values into
# data generators

class_name LevelData

@export var is_day: bool = true
@export var npc_quota: int = 10

@export_category("Personality Distribution")

@export_group("Sociable Weights")
@export var sociable_normal: float = 1
@export var sociable_social: float = 1
@export var sociable_antisocial: float = 1
@export var sociable_rushed: float = 1
@export var sociable_harasser: float = 1

@export_group("Cat Opinion Weights")
@export var opinion_love: float = 1
@export var opinion_like: float = 1
@export var opinion_dislike: float = 1
@export var opinion_allergic: float = 1

@export_group("Modifier Chances")
@export var modifier_empathetic = 0.1

var personality_sociables = Personality.Sociable.values()
var personality_cat_opinion = Personality.CatOpinion.values()
var sociable_weights: Array[float]
var sociable_weights_sum: float
var cat_opinion_weights: Array[float]
var cat_opinion_weights_sum: float

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	var sociables := {
		Personality.Sociable.NORMAL: sociable_normal,
		Personality.Sociable.SOCIAL: sociable_social,
		Personality.Sociable.ANTISOCIAL: sociable_antisocial,
		Personality.Sociable.RUSHED: sociable_rushed,
		Personality.Sociable.HARASSER: sociable_harasser,
	}
	var cat_opinions := {
		Personality.CatOpinion.LOVE: opinion_love,
		Personality.CatOpinion.LIKE: opinion_like,
		Personality.CatOpinion.DISLIKE: opinion_dislike,
		Personality.CatOpinion.ALLERGIC: opinion_allergic,
	}
	sociable_weights = _create_weight_accumulator(Personality.Sociable.values(), sociables)
	cat_opinion_weights = _create_weight_accumulator(Personality.CatOpinion.values(), cat_opinions)

func generate_sociable() -> Personality.Sociable:
	var index: int = _choose_weighted(sociable_weights)
	return personality_sociables[index]

func generate_cat_opinion() -> Personality.CatOpinion:
	var index: int = _choose_weighted(cat_opinion_weights)
	return personality_cat_opinion[index]

func generate_modifiers() -> Array[Personality.Modifier]:
	var modifiers: Array[Personality.Modifier] = []
	if randf() < modifier_empathetic:
		modifiers.append(Personality.Modifier.EMPATHETIC)
	return modifiers

func _choose_weighted(weights_acc: Array[float]) -> int:
	var sum: float = weights_acc[-1]
	var target: float = randf() * sum
	for i in weights_acc.size():
		if weights_acc[i] >= target:
			return i
	assert(false)
	return -1

	
func _create_weight_accumulator(from_array: Array, value_dictionary : Dictionary) -> Array[float]:
	var weight_acc: Array[float] = []
	weight_acc.resize(from_array.size())
	var weights_sum: float = 0.0
	for i in weight_acc.size():
		var item = from_array[i]
		var value = value_dictionary[item]
		weights_sum += value
		weight_acc[i] = weights_sum
	return weight_acc

func _get_sum(array: Array[float]) -> float:
	var sum: float = 0.0
	for item: float in array:
		sum += item
	return sum
