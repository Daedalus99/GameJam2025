@tool
class_name Corpse
extends PathFollow3D

@export var chopSpotContainer : Node3D
signal harvest_complete
@export var remaining : int = 0
@export var workAreaCollider: PhysicsBody3D

# Conveyor belt
@export var kill_at_end: bool = true
@export var speed : float = 1.0
@export var drive : float = 0.0
@export var visuals: Node3D

func _ready() -> void:
	remaining = 0
	var spots = chopSpotContainer.get_children()
	for s in spots:
		if s.has_signal("extracted"):
			s.connect("extracted", _on_spot_extracted)
			remaining += 1
	rotation_mode = PathFollow3D.ROTATION_NONE  # or ROTATION_ORIENTED
	loop = false
	progress = 0.0

func set_drive(on: bool) -> void:
	drive = 1.0 if on else 0.0

func _physics_process(delta: float) -> void:
	progress += speed * drive * delta
	if kill_at_end and progress_ratio >= 1.0:
		queue_free()

func _on_spot_extracted(harvestData) -> void:
	remaining -= 1
	if remaining <= 0:
		workAreaCollider.queue_free()
		emit_signal("harvest_complete")
