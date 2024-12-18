extends Node2D

@onready var building:TileMapLayer = $Buildings
@onready var target := $Buildings/Target
@onready var building_placer = $BuildingPlacer

const CONSTRUCTION := Vector2i(3, 6)

var turn := 0
var pop := 0
var food := 0
var morale := 0
var constructions := []

func _ready() -> void:
	$UI.show()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("esc"):
		get_tree().quit()
		
func global_mouse_to_building_coords()->Vector2i:
	return building.local_to_map(building.to_local(get_global_mouse_position()))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if building_placer.visible:
			var map_coord = global_mouse_to_building_coords()
			add_construction(map_coord, randi()%3+1, $UI.last_atlas, $UI.last_source_id)
			#building.set_cell(map_coord, $UI.last_source_id, $UI.last_atlas)
		else:
			var coord = global_mouse_to_building_coords()
			var data = building.get_cell_tile_data(coord)
			var type = ""
			if data:
				type = data.get_custom_data("type")
				target.position = building.map_to_local(coord)
			if type == "warehouse":
				$UI/Info.show_warehouse(coord, pop, food, morale)
			else:
				$UI/Info.read_atlas(type, coord)
	elif event.is_action_pressed("cancel"):
		building_placer.hide()
	elif event is InputEventMouseMotion and building_placer.visible:
		building_placer.position = building.map_to_local(global_mouse_to_building_coords())


func _on_turn_pressed() -> void:
	building_placer.hide()
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
	var del = []
	for i in constructions.size():
		var c = constructions[i]
		c[&"turns_left"] -= 1
		if c[&"turns_left"] <= 0:
			building.set_cell(c.location, c.source, c.atlas)
			del.push_front(i)
	for d in del:
		constructions.remove_at(d)


func _on_ui_selected_building(atlas_coords, source_id):
		var source:TileSetAtlasSource = building.tile_set.get_source(source_id)
		building_placer.region_rect = source.get_tile_texture_region(atlas_coords)
		building_placer.show()


func add_construction(location:Vector2i, turns_left:int, atlas:Vector2i, source:int):
	building.set_cell(location, source, CONSTRUCTION)
	constructions.append({&"location": location, &"turns_left": turns_left,
	&"atlas": atlas, &"source": source})
