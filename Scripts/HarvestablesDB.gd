class_name HarvestablesDB
extends Resource

@export var items: Array[HarvestableData]
var by_id: Dictionary = {}

func build_index() -> void:
	by_id.clear()
	for h in items:
		if h: by_id[h.id] = h

func get_data_by_id(id: StringName) -> HarvestableData:
	return by_id.get(id)

func random(filter: Callable = Callable()) -> HarvestableData:
	var pool: Array[HarvestableData] = []
	for h in items:
		if h and (not filter.is_valid() or filter.call(h)):
			pool.append(h)
	return null if pool.is_empty() else pool[randi() % pool.size()]
