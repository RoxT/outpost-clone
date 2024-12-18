extends Node2D

@onready var building:TileMapLayer = $Buildings
@onready var target := $Buildings/Target
var turn := 0
var pop := 0
var food := 0
var morale := 0

func _ready() -> void:
	$UI.show()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("esc"):
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var coord = building.local_to_map(building.to_local(get_global_mouse_position()))
			var data = building.get_cell_tile_data(coord)
			var type = ""
			if data:
				type = data.get_custom_data("type")
				target.position = building.map_to_local(coord)
			if type == "warehouse":
				$UI/Info.show_warehouse(coord, pop, food, morale)
			else:
				$UI/Info.read_atlas(type, coord)


func _on_turn_pressed() -> void:
	var new_food := 0
	var new_pop := 0
	var new_morale := 0
	for coord in building.get_used_cells():
		var terrain_data = $Terrain.get_cell_tile_data(coord)
		if terrain_data:
			new_food += terrain_data.get_custom_data("food")
		var building_data = building.get_cell_tile_data(coord)
		if building_data:
			new_food += building_data.get_custom_data("food")
			new_pop += building_data.get_custom_data("pop")
			new_morale += building_data.get_custom_data("morale")
	food += new_food
	pop = new_pop
	morale = new_morale
	turn += 1
	$UI/Turn.text = "Turn %s" % turn
