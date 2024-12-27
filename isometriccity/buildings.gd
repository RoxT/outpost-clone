extends TileMapLayer

const PICKER = preload("res://colony_picker.tscn")
const SEED_ATLAS := Vector2i(3,2)
@export var surface := true
@export var colony_name:String

func _ready() -> void:
	if surface:
		var seed_pos = map_to_local(get_used_cells_by_id(0, SEED_ATLAS)[0])
		var picker = PICKER.instantiate()
		add_child(picker)
		picker.position = seed_pos
		picker.input_event.connect(get_parent().get_parent()._on_colony_picker_input_event.bind(get_index()))
	assert(not colony_name.is_empty())
