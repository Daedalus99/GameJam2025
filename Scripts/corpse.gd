@tool
class_name Corpse
extends PathFollow3D

@export var chopSpotContainer: Node3D

# Conveyor belt
@export var kill_at_end: bool = true
@export var speed : float = 1.0
@export var drive : float = 0.0
@export var visuals: Node3D

func _ready() -> void:
	rotation_mode = PathFollow3D.ROTATION_NONE  # or ROTATION_ORIENTED
	loop = false
	progress = 0.0

func set_drive(on: bool) -> void:
	drive = 1.0 if on else 0.0

func _physics_process(delta: float) -> void:
	progress += speed * drive * delta
	if kill_at_end and progress_ratio >= 1.0:
		queue_free()
