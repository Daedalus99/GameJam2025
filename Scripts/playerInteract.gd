extends Node3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D

var last_hover: Node = null

func _physics_process(_dt: float) -> void:
	var hit := ray.get_collider()
	# clear old hover
	if last_hover and is_instance_valid(last_hover) and last_hover.has_method("set_hover"):
		last_hover.set_hover(false)
	last_hover = null

	# set new hover
	if hit and hit.has_method("set_hover"):
		hit.set_hover(true)
		last_hover = hit

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var hit := ray.get_collider()
		if hit and hit.has_method("activate"):
			hit.activate()
