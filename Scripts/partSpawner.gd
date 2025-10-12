extends Node3D

@export var path: Path3D
@export var scene_to_spawn: PackedScene = preload("res://Prefabs/Corpse.tscn")
@export var conveyor_speed := 1.0
@export var spawn_interval := 3.0
@export var work_zone: Area3D   # assign the Area3D in inspector

@onready var timer: Timer = $SpawnTimer
@onready var belt: CSGBox3D = $Belt

var belt_mat: ShaderMaterial
var moving := false
var phase := 0.0
@export var speed_uv_per_sec := Vector2(0.0, -1.0)
const SCROLL_SHADER: Shader = preload("res://scroll_uv.gdshader")

var active_corpse: Node = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

	# belt material
	if belt.material is ShaderMaterial:
		belt_mat = belt.material.duplicate()
	else:
		belt_mat = ShaderMaterial.new()
		belt_mat.shader = SCROLL_SHADER
	belt.material = belt_mat
	belt_mat.set_shader_parameter("scroll_speed", speed_uv_per_sec)
	belt_mat.set_shader_parameter("phase", phase)

	# spawn timer
	timer.wait_time = spawn_interval
	timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	timer.ignore_time_scale = false
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

	# zone
	if work_zone:
		work_zone.body_entered.connect(_on_zone_entered)

	_set_conveyor_drive(true)  # start moving

func _process(delta: float) -> void:
	if moving and not get_tree().paused:
		phase += delta
		belt_mat.set_shader_parameter("phase", phase)

func _on_timer_timeout() -> void:
	var corpse := scene_to_spawn.instantiate()
	path.add_child(corpse)
	# expect corpse script to have .speed and .set_drive()
	corpse.call("set_drive", moving)
	corpse.set("speed", conveyor_speed)
	corpse.add_to_group("conveyor")

func _on_zone_entered(body: Node) -> void:
	var n := body
	while n and not (n is Corpse):
		n = n.get_parent()
	if n == null: return
	if active_corpse != null: return
	active_corpse = n
	_set_conveyor_drive(false)
	(active_corpse as Corpse).harvest_complete.connect(_on_corpse_done.bind(active_corpse))

func _on_corpse_done(done: Corpse) -> void:
	if active_corpse == done:
		active_corpse = null
		_set_conveyor_drive(true)

func _set_conveyor_drive(on: bool) -> void:
	moving = on
	get_tree().call_group("conveyor", "set_drive", on)
	$BeltAudio.set_drive(on)
