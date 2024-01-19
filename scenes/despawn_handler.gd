extends Node2D

class_name DespawnHandler

signal on_npc_despawned

func _on_left_body_entered(body: Node2D) -> void:
	_handle_node(body, false)

func _on_right_body_entered(body: Node2D) -> void:
	_handle_node(body, true)
	
func _handle_node(node: Node2D, is_right: bool) -> void:
	if not (node is NPC):
		return
	var npc: NPC = node as NPC
	var moving_east: bool = npc.behavior.is_moving_east()
	if moving_east == is_right:
		if npc.despawn():
			on_npc_despawned.emit()
