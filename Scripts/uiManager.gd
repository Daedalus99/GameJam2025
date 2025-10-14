extends Control

@export var main_menu_scene: PackedScene
@onready var counter_ui: PackedScene = preload("res://Prefabs/harvestableCounter.tscn")

@onready var pause_menu: Control = $PauseMenu
@onready var resume_btn: Button = $PauseMenu/Buttons/ResumeButton
@onready var exit_btn: Button = $PauseMenu/Buttons/ExitToMenuButton
@onready var quit_btn: Button = $PauseMenu/Buttons/QuitButton
@export var beltAudioContainer: BeltAudio

var inventory: Dictionary[String, int]
@onready var itemCountersContainer : VBoxContainer = $Gameplay/ItemCounts

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Godot 4
	pause_menu.visible = false
	get_tree().node_added.connect(_on_node_added)
	resume_btn.pressed.connect(_on_resume_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

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

func _on_node_added(n: Node) -> void:
	# Auto-wire any ChopSpot-like node that emits `extracted`
	# print("Node Added! %s" % n)
	if n.has_signal("extracted"):
		n.connect("extracted", Callable(self, "add_harvestable_to_inventory"))
		
func add_harvestable_to_inventory(h: HarvestableData):
	print("Adding harvestable: %s" % h.id)
	var new_count = inventory.get(h.id, 0) + h.choose_yield()
	if h.id not in inventory:
		print("Adding new counter UI for harvestable.")
		var counterTex = counter_ui.instantiate() as TextureRect
		counterTex.texture = h.icon
		counterTex.name = h.id
		itemCountersContainer.add_child(counterTex)
	inventory[h.id] = new_count
	(itemCountersContainer.find_child(h.id, true, false).get_child(0) as Label).text = "x%02d" % new_count 
	
