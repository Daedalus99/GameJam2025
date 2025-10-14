class_name ChopSpot
extends Area3D
@export var harvestData: HarvestableData
@export var modelSwap: MeshInstance3D
@export var baseModel: MeshInstance3D
signal extracted(harvestable: HarvestableData)
@onready var highlight: Label3D =  $Highlight
var armed := true

func _ready() -> void:
	highlight.text = harvestData.display_name
	highlight.no_depth_test = true          # draws even if slightly occluded

func set_hover(on: bool) -> void:
	if is_instance_valid(highlight):
		highlight.visible = on

func activate() -> void:
	if not armed: return
	armed = false
	if is_instance_valid(highlight):
		highlight.visible = false
	extracted.emit(harvestData)
	print("Harvested ", harvestData.display_name)
	modelSwap.visible = true
	baseModel.visible = false
	queue_free()
