extends Node3D

@export var customerPrefab: PackedScene = preload("res://Prefabs/Customer.tscn")
@export var maxCustomers: int = 3
@export var customerSpacing: float = 2.0
@export var customerSpeed: float = 2.0
@export var newCustomerFreqRange: Vector2 = Vector2(10, 30)

@onready var queuePath: Path3D = $QueuePath
@onready var checkoutZone: Area3D = $CheckoutZone
@onready var spawnTimer: Timer = $SpawnTimer

enum State { QUEUE, IN_ZONE, LEAVING }

@export var carriers: Array[PathFollow3D] = []           # order = front..back
@export var state_by: Dictionary = {}                    # PathFollow3D -> State
@export var path_len := 0.0
@export var checkout_offset := 0.0

func _ready() -> void:
	path_len = queuePath.curve.get_baked_length()
	
	var p_local := queuePath.to_local(checkoutZone.global_transform.origin)
	checkout_offset = clamp(queuePath.curve.get_closest_offset(p_local), 0.0, path_len)

	checkoutZone.body_entered.connect(_on_checkout_entered)

	spawnTimer.one_shot = true
	spawnTimer.timeout.connect(_on_spawn_timer_timeout)
	_on_spawn_timer_timeout()

func _physics_process(dt: float) -> void:
	if carriers.size() == 0: return

	# front mover
	var front := carriers[0]
	if state_by.get(front, State.QUEUE) == State.QUEUE:
		front.progress = _forward_toward(front.progress, checkout_offset, customerSpeed * dt)

	# followers keep spacing to the previous and never move backward
	for i in range(1, carriers.size()):
		var prev := carriers[i - 1]
		var cur := carriers[i]
		match state_by.get(cur, State.QUEUE):
			State.QUEUE:
				var target := float(min(checkout_offset, prev.progress - customerSpacing))
				target = max(target, cur.progress) # no backward
				cur.progress = _forward_toward(cur.progress, target, customerSpeed * dt)
			State.LEAVING:
				cur.progress = _forward_toward(cur.progress, path_len, customerSpeed * dt)
			State.IN_ZONE:
				# should not happen for followers; keep still
				pass

	# cleanup leavers at end
	for i in range(carriers.size()-1, -1, -1):
		var m := carriers[i]
		if state_by.get(m, State.QUEUE) == State.LEAVING and m.progress >= path_len - 0.01:
			m.queue_free()
			carriers.remove_at(i)
			state_by.erase(m)

	# re-arm spawn if under cap
	if carriers.size() < maxCustomers and spawnTimer.is_stopped():
		_arm_spawn()

func _on_checkout_entered(body: Node) -> void:
	var m := _find_mover(body)
	if m == null: return
	print("Customer entered checkout zone")
	# only stop the front one at the zone
	if carriers.size() > 0 and m == carriers[0]:
		state_by[m] = State.IN_ZONE

# call this when the current front customer is served
func serve_front() -> void:
	if carriers.size() == 0: return
	var m := carriers[0]
	state_by[m] = State.LEAVING
	# shift the queue: the new front may still be approaching checkout_offset

# --- spawning ---

func _arm_spawn() -> void:
	if carriers.size() >= maxCustomers: return
	spawnTimer.wait_time = randf_range(newCustomerFreqRange.x, newCustomerFreqRange.y)
	spawnTimer.start()

func _on_spawn_timer_timeout() -> void:
	if carriers.size() >= maxCustomers:
		_arm_spawn()
		return

	var mover := PathFollow3D.new()
	mover.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	queuePath.add_child(mover)

	mover.progress = 0.0  # always spawn at path start

	var cust := customerPrefab.instantiate()
	mover.add_child(cust)

	carriers.append(mover)
	print("Setting state to QUEUE")
	state_by[mover] = State.QUEUE

	_arm_spawn()

# --- helpers ---

func _forward_toward(a: float, b: float, d: float) -> float:
	# Move forward toward b, never backward, clamp to [0, path_len].
	if b <= a: return a
	return min(a + d, b, path_len)

func _find_mover(n: Node) -> PathFollow3D:
	var x := n
	while x and not (x is PathFollow3D):
		x = x.get_parent()
	return x
