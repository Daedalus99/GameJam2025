extends Node3D

@export var path: Path3D
@export var scene_to_spawn: PackedScene = preload("res://Prefabs/Corpse.tscn")
@export var conveyor_speed := 1.0
@export var move_duration := 1.0
@export var stop_duration := 1.0

@onready var timer: Timer = $SpawnTimer
@onready var belt: CSGBox3D = $Belt
var belt_mat: ShaderMaterial

const SCROLL_SHADER: Shader = preload("res://scroll_uv.gdshader")

func _ready() -> void:
	# per-instance ShaderMaterial on the belt
	if belt.material is ShaderMaterial:
		belt_mat = belt.material.duplicate()
	else:
		belt_mat = ShaderMaterial.new()
		belt_mat.shader = SCROLL_SHADER
	belt.material = belt_mat
	# set UV scroll speed once
	belt_mat.set_shader_parameter("scroll_speed", Vector2(0.0, -conveyor_speed))
	belt_mat.set_shader_parameter("drive", 0.0)

	timer.wait_time = move_duration + stop_duration
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	# spawn
	var corpse := scene_to_spawn.instantiate() as Corpse
	corpse.rotate_y(randf_range(0.0, TAU))
	path.add_child(corpse)
	corpse.speed = conveyor_speed
	corpse.add_to_group("conveyor")

	# move for N, then stop for N
	_set_conveyor_drive(true)
	await get_tree().create_timer(move_duration).timeout
	_set_conveyor_drive(false)
	# the timer itself enforces the stop duration until next spawn

func _set_conveyor_drive(on: bool) -> void:
	if belt_mat:
		belt_mat.set_shader_parameter("drive", 1.0 if on else 0.0)
	get_tree().call_group("conveyor", "set_drive", on)
