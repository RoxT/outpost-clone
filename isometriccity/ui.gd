extends CanvasLayer

const SURFACE_PNG := preload("res://buildings.png")
const UNDERGROUND_PNG := preload("res://u_buildings.png")

var last_atlas := Vector2i.ZERO
var last_source_id := 0

var last_chosen_s := Vector2i.ZERO
var last_chosen_u := Vector2i.ZERO

signal selected_building(atlas_coords, source_id)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func toggle_level(surface:bool):
	var last = last_chosen_s if surface else last_chosen_u
	var source = 0 if surface else 2
	$BuildPicker/BuildSelect.set_cell(Vector2i.ZERO, source, last)

func _on_build_picker_gui_input(event:InputEvent):
	if event.is_action_pressed("select"):
		var tex = SURFACE_PNG if $/root/Main.building_layer.surface else UNDERGROUND_PNG
		$ChooseBuilding/AllBuildings.texture = tex
		$ChooseBuilding.show()

func _on_all_buildings_gui_input(event:InputEvent):
	if event.is_action_pressed("select"):
		var build_selector:TileMapLayer = $BuildPicker/BuildSelect
		var point := Vector2i($ChooseBuilding/AllBuildings.get_local_mouse_position()
		/Vector2(128.0,64.0))
		
		last_source_id = 0 if $ChooseBuilding/AllBuildings.texture == SURFACE_PNG else 2
		var source:TileSetAtlasSource = build_selector.tile_set.get_source(last_source_id)
		
		last_atlas = source.get_tile_at_coords(point)
		if last_source_id == 0:
			last_chosen_s = last_atlas
		else:
			last_chosen_u = last_atlas
		
		$BuildPicker/BuildSelect.set_cell(Vector2i.ZERO, last_source_id, last_atlas)
		selected_building.emit(last_atlas, last_source_id)
		$ChooseBuilding.hide()

func _on_choose_building_gui_input(event:InputEvent):
	if event.is_action_pressed("select"):
		var build_selector:TileMapLayer = $BuildPicker/BuildSelect
		last_source_id = build_selector.get_cell_source_id(Vector2i.ZERO)
		last_atlas = build_selector.get_cell_atlas_coords(Vector2i.ZERO)
		if last_source_id == 0:
			last_chosen_s = last_atlas
		else:
			last_chosen_u = last_atlas
		$BuildPicker/BuildSelect.set_cell(Vector2i.ZERO, last_source_id, last_atlas)
		selected_building.emit(last_atlas, last_source_id)
		$ChooseBuilding.hide()
