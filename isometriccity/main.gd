extends Node2D

@onready var building_placer = $BuildingPlacer

const CONSTRUCTION := Vector2i(3, 0)
const TUBE := Vector2i(2,6)
const U_BUILDING_SOURCE := 2
const BUILDING_SOURCE := 0
const TERRAIN_SOURCE = 2
enum Robots {DOZER, DIGGER, MINER}
const ROBOT_SOURCE = 3

var turn := 0
var pop := [0]
var food := [0]
var morale := [0]
var constructions :Array[Robot] = []
@onready var building_layer:TileMapLayer = $Surface.get_child(0)
@onready var terrain_layer:TileMapLayer = $Terrain

func _ready() -> void:
	toggle_level(true)
	$UI.show()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("esc"):
		get_tree().quit()
		
func global_mouse_to_building_coords()->Vector2i:
	return building_layer.local_to_map(building_layer.to_local(get_global_mouse_position()))

func toggle_level(surface:bool):
	var i = building_layer.get_index()
	for u in $Underground.get_children():
		u.visible = not surface
	for s in $Surface.get_children():
		s.visible = surface
	$UI/SurfaceBtn.text = "Surface" if surface else "Ground"
	$Terrain.visible = surface
	$UTerrain.visible = not surface
	building_layer = $Surface.get_child(i) if surface else $Underground.get_child(i)
	terrain_layer = $Terrain if surface else $UTerrain
	$UI/ChooseBuilding.hide()
	$BuildingPlacer.hide()
	$UI.toggle_level(surface)

func switch_colony(new_i:int):
	building_layer = $Surface.get_child(new_i) if building_layer.surface else $Underground.get_child(new_i)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		var c_i := building_layer.get_index()
		if building_placer.visible:
			var surface = building_layer.surface
			var map_coord = global_mouse_to_building_coords()
			var terrain:TileMapLayer = $Terrain if surface else $UTerrain
			var terrain_x = terrain.get_cell_atlas_coords(map_coord).x
			if terrain_x > -1:
				add_construction(map_coord, terrain_x+1, $UI.last_atlas, 
				$UI.last_source_id, surface, c_i)
			#building.set_cell(map_coord, $UI.last_source_id, $UI.last_atlas)
		else:
			var coord = global_mouse_to_building_coords()
			var data = building_layer.get_cell_tile_data(coord)
			var type = ""
			if data:
				type = data.get_custom_data("type")
			if type == &"warehouse":
				$UI/Info.show_warehouse(coord, pop[c_i], food[c_i], morale[c_i])
			elif type == &"seed":
				$UI/Info.show_seed_capsule(coord, building_layer.colony_name)
			else:
				$UI/Info.read_atlas(type, coord)
	elif event.is_action_pressed("cancel"):
		building_placer.hide()
	elif event is InputEventMouseMotion and building_placer.visible:
		building_placer.position = building_layer.map_to_local(global_mouse_to_building_coords())


func _on_turn_pressed() -> void:
	building_placer.hide()
	$Terrain.do_turn()
	for colony_i in $Surface.get_child_count():
		var new_food := 0
		var new_pop := 0
		var new_morale := 0
		for layer in [$Surface.get_child(colony_i), $Underground.get_child(colony_i)]:
			var surface_layer = $Surface.get_child(colony_i)
			for coord in surface_layer.get_used_cells():
				var terrain_data = $Terrain.get_cell_tile_data(coord)
				if terrain_data:
					new_food += terrain_data.get_custom_data("food")
				var building_data = surface_layer.get_cell_tile_data(coord)
				if building_data:
					new_food += building_data.get_custom_data("food")
					new_pop += building_data.get_custom_data("pop")
					new_morale += building_data.get_custom_data("morale")
		food[colony_i] += new_food
		pop[colony_i] = new_pop
		morale[colony_i] = new_morale
	turn += 1
	$UI/Turn.text = "Turn %s" % turn
			
	var del = []
	for i in constructions.size():
		var c:Robot = constructions[i]
		c.turns_left -= 1
		if c.turns_left <= 0:
			var layer:TileMapLayer = $Surface.get_child(c.index) if c.surface else $Underground.get_child(c.index)
			var type = layer.tile_set.get_source(c.source).get_tile_data(c.atlas, 0).get_custom_data("type")
			if type == "dozer":
				terrain_layer.set_cell(c.location, $Terrain.TERRAIN_ID, $Terrain.LowLands)
				layer.erase_cell(c.location)
			elif type == "miner":
				layer.erase_cell(c.location) # No mine!
			elif type == "digger":
				var surface_layer:TileMapLayer = $Surface.get_child(c.index)
				var underground_layer:TileMapLayer = $Underground.get_child(c.index)
				layer.erase_cell(c.location)
				if c.surface:
					surface_layer.set_cell(c.location, BUILDING_SOURCE, TUBE)
					underground_layer.set_cell(c.location, BUILDING_SOURCE, TUBE)
				var neighbours = underground_layer.get_surrounding_cells(c.location)
				$UTerrain.set_smooth(c.location)
				for cell in neighbours:
					$UTerrain.set_rough(cell)
			elif type == "seed":
				var old_colony_i = layer.get_index()
				var old_colony:TileMapLayer = $Surface.get_child(old_colony_i)
				old_colony.erase_cell(c.location)
				var new_surface:TileMapLayer = $Surface.get_child(old_colony_i).duplicate()
				new_surface.clear()
				new_surface.set_cell(c.location, c.source, c.atlas)
				new_surface.colony_name = "Colony%s" % ($Surface.get_child_count() + 1)
				var new_underground:TileMapLayer = $Underground.get_child(old_colony_i).duplicate()
				new_underground.clear()
				new_underground.colony_name = "Colony%s" % $Underground.get_child_count()
				new_underground.surface = false
				$Surface.add_child(new_surface)
				$Underground.add_child(new_underground)
				pop.append(0)
				morale.append(0)
				food.append(50)
				food[old_colony_i] -= 50
			else:
				layer.set_cell(c.location, c.source, c.atlas)
			del.push_front(i)
	for d in del:
		constructions.remove_at(d)


func _on_ui_selected_building(atlas_coords, source_id):
	var source:TileSetAtlasSource = building_layer.tile_set.get_source(source_id)
	building_placer.texture = source.texture
	building_placer.region_rect = source.get_tile_texture_region(atlas_coords)
	building_placer.show()


func add_construction(location:Vector2i, turns_left:int, 
atlas:Vector2i, source:int, surface:bool, index:int):
	if source == ROBOT_SOURCE:
		building_layer.set_cell(location, source, atlas)
	else:
		building_layer.set_cell(location, ROBOT_SOURCE, CONSTRUCTION)
	constructions.append(Robot.new(location, turns_left, atlas, source, surface, index))

class Robot:
	var location:Vector2i
	var turns_left:int
	var atlas:Vector2i
	var source:int
	var surface:bool
	var index:int
	func _init(new_location, new_turns_left, new_atlas, new_source, new_surface, new_index):
		location = new_location
		turns_left = new_turns_left
		atlas = new_atlas
		source = new_source
		surface = new_surface
		index = new_index


func _on_surface_btn_toggled(toggled_on):
	toggle_level(toggled_on)

func _on_generate_pressed():
	$Terrain.generate_planet()

func _on_colony_picker_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, colony_i:int) -> void:
	if event.is_action_pressed("select"):
		switch_colony(colony_i)
		
		var ev = InputEventAction.new()
		# Set as ui_left, pressed.
		ev.action = "select"
		ev.pressed = true
		# Feedback.
		Input.parse_input_event(ev)
