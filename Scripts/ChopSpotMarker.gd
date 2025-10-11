@tool
extends Node3D
class_name ChopSpotMarker
signal changed

@export var id: String = "Heart": set = set_id
func set_id(v: String) -> void:
	id = v
	name = v
	emit_signal("changed")

func _notification(what: int) -> void:
	if Engine.is_editor_hint() and what == NOTIFICATION_TRANSFORM_CHANGED:
		emit_signal("changed")
