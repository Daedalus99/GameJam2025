extends Control

@export var main_menu_scene: PackedScene
@export var counters_container: NodePath = ^"Counters"

@onready var pause_menu: Control = $PauseMenu
@onready var resume_btn: Button = $PauseMenu/Buttons/ResumeButton
@onready var exit_btn: Button = $PauseMenu/Buttons/ExitToMenuButton
@onready var quit_btn: Button = $PauseMenu/Buttons/QuitButton
@onready var counters_root: Node = get_node(counters_container)
@export var beltAudioContainer: BeltAudio

var counts := {}         # { "Heart": 0, ... }
var labels := {}         # { "Heart": Label, ... }

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Godot 4
	pause_menu.visible = false
	_build_counter_map()

	resume_btn.pressed.connect(_on_resume_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

	# Auto-connect to any ChopSpot entering the tree
	get_tree().node_added.connect(_on_node_added)

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		if get_tree().paused: _resume_game()
		else: _pause_game()

# --- Pause control ---
func _pause_game() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_menu.visible = true
	beltAudioContainer.set_paused(true)

func _resume_game() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	beltAudioContainer.set_paused(false)


func _on_resume_pressed() -> void: _resume_game()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	if main_menu_scene:
		get_tree().change_scene_to_packed(main_menu_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()

# --- Counters ---
func _build_counter_map() -> void:
	if counters_root == null: return
	for n in counters_root.get_children():
		if n is Label:
			var pt : String = str(n.get_meta("part_type")) if n.has_meta("part_type") else str(n.name)
			labels[pt] = n
			counts[pt] = 0
			_update_label(pt)

func _on_node_added(n: Node) -> void:
	# Support either signal name
	if n.has_signal("extracted"):
		n.connect("extracted", _on_extracted)             # (part_type, quality)
	elif n.has_signal("harvested"):
		n.connect("harvested", _on_harvested)             # (part_type)

func _on_extracted(part_type: String, _quality: String) -> void:
	_inc(part_type)

func _on_harvested(part_type: String) -> void:
	_inc(part_type)

func _inc(pt: String) -> void:
	counts[pt] = counts.get(pt, 0) + 1
	_update_label(pt)

func _update_label(pt: String) -> void:
	if labels.has(pt):
		labels[pt].text = "%s: %d" % [pt, counts[pt]]
