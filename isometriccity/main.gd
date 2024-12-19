extends Node2D

@onready var target := $Buildings/Target
@onready var building_placer = $BuildingPlacer

const CONSTRUCTION := Vector2i(3, 6)

var turn := 0
var pop := 0
var food := 0
var morale := 0
var constructions := []
@onready var building_layer:TileMapLayer = $Buildings
@onready var terrain_layer:TileMapLayer = $Terrain

func _ready() -> void:
	toggle_ground(true)
	$UI.show()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("esc"):
		get_tree().quit()
		
func global_mouse_to_building_coords()->Vector2i:
	return building_layer.local_to_map(building_layer.to_local(get_global_mouse_position()))

func toggle_ground(surface:bool):
	$Terrain.visible = surface
	$Buildings.visible = surface
	$UTerrain.visible = not surface
	$UBuildings.visible = not surface
	building_layer = $Buildings if surface else $UBuildings
	terrain_layer = $Terrain if surface else $UTerrain

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if building_placer.visible:
			var surface = building_layer == $Buildings
			var map_coord = global_mouse_to_building_coords()
			add_construction(map_coord, randi()%3+1, $UI.last_atlas, 
			$UI.last_source_id, surface)
			#building.set_cell(map_coord, $UI.last_source_id, $UI.last_atlas)
		else:
			var coord = global_mouse_to_building_coords()
			var data = building_layer.get_cell_tile_data(coord)
			var type = ""
			if data:
				type = data.get_custom_data("type")
				target.position = building_layer.map_to_local(coord)
			if type == "warehouse":
				$UI/Info.show_warehouse(coord, pop, food, morale)
			else:
				$UI/Info.read_atlas(type, coord)
	elif event.is_action_pressed("cancel"):
		building_placer.hide()
	elif event is InputEventMouseMotion and building_placer.visible:
		building_placer.position = building_layer.map_to_local(global_mouse_to_building_coords())


func _on_turn_pressed() -> void:
	building_placer.hide()
	var new_food := 0
	var new_pop := 0
	var new_morale := 0
	for coord in building_layer.get_used_cells():
		var terrain_data = $Terrain.get_cell_tile_data(coord)
		if terrain_data:
			new_food += terrain_data.get_custom_data("food")
		var building_data = building_layer.get_cell_tile_data(coord)
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
			var layer:TileMapLayer = $Buildings if c.surface else $UBuildings
			if layer.tile_set.get_source(0).get_tile_data(c.atlas, 0).get_custom_data("type") == "tube":
				$Buildings.set_cell(c.location, c.source, c.atlas)
				$UBuildings.set_cell(c.location, c.source, c.atlas)
			else:
				layer.set_cell(c.location, c.source, c.atlas)
			del.push_front(i)
	for d in del:
		constructions.remove_at(d)


func _on_ui_selected_building(atlas_coords, source_id):
		var source:TileSetAtlasSource = building_layer.tile_set.get_source(source_id)
		building_placer.region_rect = source.get_tile_texture_region(atlas_coords)
		building_placer.show()

func add_construction(location:Vector2i, turns_left:int, 
atlas:Vector2i, source:int, surface:bool):
	building_layer.set_cell(location, source, CONSTRUCTION)
	constructions.append({&"location": location, &"turns_left": turns_left,
	&"atlas": atlas, &"source": source, &"surface":surface})

func _on_surface_btn_toggled(toggled_on):
	toggle_ground(toggled_on)
