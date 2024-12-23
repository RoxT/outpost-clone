extends TileMapLayer

@export var noise:NoiseTexture2D

const LowLands := [Vector2i(0,1)]
const Lands := [Vector2i(1, 1), Vector2i(1,2), Vector2i(2, 1)]
const HighLands := [Vector2i(2,2),Vector2i(2,3),Vector2i(3,2)]
const Waters = [Vector2i(1,4)]
const LowWaters := [Vector2i(2,4)]

const WaterLife := Vector2i(3, 0)
const PlantLife := Vector2i(0,2)
const TreeLife := Vector2i(3, 3)
const Empty := Vector2i(-1,-1)

const DIRS := [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN,
	Vector2i(1,1), Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1)]

# Called when the node enters the scene tree for the first time.
func do_turn():
	var cells = get_used_cells()
	var count := 0
	var new_atlas := {}
	var life:TileMapLayer = $Life
	for cell in cells:
		if life.get_cell_source_id(cell) > -1:
			count += 1
			var neighbours = 0
			for dir in DIRS:
				if life.get_cell_source_id(cell+dir) > -1:
					neighbours += 1
					if neighbours > 3:
						new_atlas[cell] = Empty
						continue
			if neighbours < 2:
				new_atlas[cell] = Empty
		else:
			var neighbours = 0
			for dir in DIRS:
				if life.get_cell_source_id(cell+dir) > -1:
					neighbours += 1
					if neighbours > 3: continue
			if neighbours == 3:
				# Do as custom data instead?
				var terrain = get_cell_atlas_coords(cell)
				if terrain in Lands or terrain in LowLands:
					new_atlas[cell] = TreeLife
				elif terrain in Waters or terrain in LowWaters:
					new_atlas[cell] = WaterLife
				elif terrain in HighLands:
					new_atlas[cell] = PlantLife
				else:
					print("unknown terrain atlas %s" % terrain)
	for cell in new_atlas:
		life.set_cell(cell, 1, new_atlas[cell])
			
	print(count)

func generate_planet():
	noise.noise.seed = randi() % 10
	var maxx := 0.0
	var minn = 0.0
	for x in noise.width:
		for y in noise.height:
			var value = noise.noise.get_noise_2d(x, y)
			maxx = max(value, maxx)
			minn = min(value, minn)
			var coord = Vector2i(x, y)
			
			if value < -0.2:
				set_cell(Vector2i(x, y), 2, LowWaters.pick_random())
				if randf() < 0.1:
					$Life.set_cell(coord, 1, WaterLife)
			elif value < 0:
				set_cell(coord, 2, Waters.pick_random())
				if randf() < 0.25:
					$Life.set_cell(coord, 1, WaterLife)
			elif value < 0.15:
				set_cell(coord, 2, LowLands.pick_random())
				if randf() < 0.1:
					$Life.set_cell(coord, 1, TreeLife)
			elif value < 0.3:
				set_cell(coord, 2, Lands.pick_random())
				if randf() < 0.05:
					$Life.set_cell(coord, 1, TreeLife)
			else:
				set_cell(coord, 2, HighLands.pick_random())
				if randf() < 0.1:
					$Life.set_cell(coord, 1, PlantLife)
	print(noise.noise.seed)
	print(minn)
	print(maxx)
	
	
