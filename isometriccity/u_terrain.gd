extends TileMapLayer


const TERRAIN_ID := 0

const Empty := Vector2i(-1,-1)

const SmoothUnderground := Vector2i(2,0)
const RoughUnderground := Vector2i(4,1)

func set_smooth(cell):
	set_cell(cell, TERRAIN_ID, SmoothUnderground)
	
func set_rough(cell):
	if get_cell_source_id(cell) == -1:
		set_cell(cell, TERRAIN_ID, RoughUnderground)
