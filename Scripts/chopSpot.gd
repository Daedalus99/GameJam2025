class_name ChopSpot
extends Area3D
@export var hotspot_id: String = "Heart"
@export var modelSwap: MeshInstance3D
@export var baseModel: MeshInstance3D
signal extracted
@onready var highlight: Label3D =  $Highlight
var armed := true

func _ready() -> void:
	highlight.text = hotspot_id

func set_hover(on: bool) -> void:
	if is_instance_valid(highlight):
		highlight.visible = on

func activate() -> void:
	if not armed: return
	armed = false
	if is_instance_valid(highlight):
		highlight.visible = false
	extracted.emit(hotspot_id, "great?")
	print("Harvested ", hotspot_id)
	modelSwap.visible = true
	baseModel.visible = false
	queue_free()
