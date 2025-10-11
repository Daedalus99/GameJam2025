class_name ChopSpot
extends Area3D
@export var hotspot_id: String = "Heart"

@onready var highlight: Node3D =  $Highlight
var armed := true

func set_hover(on: bool) -> void:
	if is_instance_valid(highlight):
		highlight.visible = on

func activate() -> void:
	if not armed: return
	armed = false
	if is_instance_valid(highlight):
		highlight.visible = false
	print("Extracted ", hotspot_id)
