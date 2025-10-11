@tool
class_name Corpse
extends PathFollow3D

@export var chopspot_scene: PackedScene = preload("res://Prefabs/ChopSpot.tscn")
@export var spots: Array[ChopSpotDef] = []

# Editor buttons
@export var sync_markers_from_list := false: set = _sync_from_list
@export var write_list_from_markers := false: set = _write_from_markers
@export var clear_markers := false: set = _clear_markers

# Conveyor belt
@export var speed : float = 1.0
@export var drive : float = 0.0

func _markers_root() -> Node3D:
	var n := get_node_or_null("HotspotMarkers") as Node3D
	if n == null:
		n = Node3D.new()
		n.name = "HotspotMarkers"
		add_child(n)
		if Engine.is_editor_hint():
			n.owner = get_tree().edited_scene_root
	return n

func _sync_from_list(v: bool) -> void:
	if not v: return
	var root := _markers_root()
	for c in root.get_children(): c.queue_free()
	for i in spots.size():
		var def := spots[i]
		if def == null: continue
		var m := ChopSpotMarker.new()
		m.name = def.id
		m.id = def.id
		m.position = def.position
		m.set_meta("spot_index", i)
		root.add_child(m)
		if Engine.is_editor_hint(): m.owner = get_tree().edited_scene_root
		m.changed.connect(_on_marker_changed.bind(m))
	sync_markers_from_list = false

func _on_marker_changed(m: ChopSpotMarker) -> void:
	var i := int(m.get_meta("spot_index"))
	if i >= 0 and i < spots.size() and spots[i] != null:
		spots[i].position = m.position
		spots[i].rotation_y = m.rotation.y
		spots[i].id = m.id

func _write_from_markers(v: bool) -> void:
	if not v: return
	var root := _markers_root()
	spots.clear()
	for m in root.get_children():
		if m is ChopSpotMarker:
			var def := ChopSpotDef.new()
			def.id = m.id
			def.position = m.position
			def.rotation_y = m.rotation.y
			spots.append(def)
	write_list_from_markers = false

func _clear_markers(v: bool) -> void:
	if not v: return
	var root := _markers_root()
	for c in root.get_children(): c.queue_free()
	clear_markers = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	var root := get_node_or_null("HotspotMarkers") as Node3D
	if root:
		for m in root.get_children():
			if m is Node3D:
				var inst : ChopSpot = chopspot_scene.instantiate()
				inst.name = m.name
				inst.transform = m.transform
				inst.hotspot_id = m.name
				add_child(inst)
		root.queue_free()

func set_drive(on: bool) -> void:
	drive = 1.0 if on else 0.0

func _physics_process(delta: float) -> void:
	progress += speed * drive * delta
