extends PathFollow3D
class_name Customer
@export var db: HarvestablesDB
@export var list_size := 1
var shopping_list: Array[HarvestableData] = []

func _ready() -> void:
	db.build_index()
	pick_random_list()

func pick_random_list() -> void:
	shopping_list.clear()
	for i in list_size:
		var h := db.random()
		if h: shopping_list.append(h)
	if list_size >= 1:
		$Visuals/Desire.visible=true
		($Visuals/Desire/HarvestableSprite as Sprite3D).texture =  shopping_list[0].icon

func checkout():
	print("Cha-CHING!")
	
