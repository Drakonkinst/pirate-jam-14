extends Resource

class_name Dialogue

@export var greet_cat: Array[String]
@export var shoo_cat: Array[String]
@export var allergic_cat: Array[String]

func _init() -> void:
	pass
	
func generate_line(list: Array[String]) -> String:
	if list.size() <= 0:
		return ""
	return list[randi() % list.size()]
