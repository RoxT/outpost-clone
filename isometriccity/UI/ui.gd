extends CanvasLayer

var last_atlas := Vector2i.ZERO
var last_source_id := 0

signal selected_building(atlas_coords, source_id)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_build_picker_gui_input(event:InputEvent):
	if event.is_action_pressed("select"):
		#var build_selector:TileMapLayer = $BuildPicker/BuildSelect
		#last_atlas = build_selector.get_cell_atlas_coords(Vector2i.ZERO)
		#last_source_id = build_selector.get_cell_source_id(Vector2i.ZERO)
		
		$ChooseBuilding.show()

func _on_all_buildings_gui_input(event:InputEvent, child_index:int, source_id:int):
	if event.is_action_pressed("select"):
		var build_selector:TileMapLayer = $BuildPicker/BuildSelect
		var point := Vector2i($ChooseBuilding.get_child(child_index).get_local_mouse_position()
		/Vector2(128.0,64.0))
		
		last_source_id = source_id
		var source:TileSetAtlasSource = build_selector.tile_set.get_source(last_source_id)
		
		last_atlas = source.get_tile_at_coords(point)
		
		$BuildPicker/BuildSelect.set_cell(Vector2i.ZERO, last_source_id, last_atlas)
		selected_building.emit(last_atlas, last_source_id)
		$ChooseBuilding.hide()

func _on_choose_building_gui_input(event:InputEvent):
	if event.is_action_pressed("select"):
		var build_selector:TileMapLayer = $BuildPicker/BuildSelect
		last_source_id = build_selector.get_cell_source_id(Vector2i.ZERO)
		last_atlas = build_selector.get_cell_atlas_coords(Vector2i.ZERO)
		$BuildPicker/BuildSelect.set_cell(Vector2i.ZERO, last_source_id, last_atlas)
		selected_building.emit(last_atlas, last_source_id)
		$ChooseBuilding.hide()
