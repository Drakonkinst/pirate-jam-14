extends RigidBody2D

func _ready() -> void:
	# Select a random model
	var mob_types: PackedStringArray = $MobModel.sprite_frames.get_animation_names()
	$MobModel.play(mob_types[randi() % mob_types.size()])

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
