extends Area2D

enum TileEffects {
	PUSH = 1
}

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		_process_tilemap_collision(body, body_rid)
