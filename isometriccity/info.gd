extends Panel

@onready var info_label := $InfoLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func show_warehouse(coords:Vector2i, pop:int, food:int, morale:int):
	info_label.clear()
	info_label.add_text("%s" % coords)
	info_label.newline()
	info_label.add_text("Warehouse.\nPop: %s\nFood: %s\nMorale: %s" % [pop, food, morale])
	
func clear():
	info_label.clear()
	
func show_seed_capsule(coords:Vector2i, col_name:String):
	info_label.clear()
	info_label.add_text("%s" % coords)
	info_label.newline()
	info_label.add_text("%s" % col_name)
	info_label.newline()
	info_label.add_text("The seed capsule provides housing and food for a small population." + 
	"\nClick on a seed capsule to switch colony views.")

func read_atlas(type:String, coords:Vector2i):
	info_label.clear()
	info_label.add_text("%s" % coords)
	info_label.newline()
	match type:
		"dome":
			info_label.add_text("A livable dome for a small population.\nPop + 100")
		"garden":
			info_label.add_text("Large nature preserve, connects buildings.\nFood + 10\nMorale + 10")
		"teamsters":
			info_label.add_text("Moves goods within 10 spaces.")
		"tower":
			info_label.add_text("Connects communications within 10 spaces.")
		"warehouse":
			print("warehouse should be called specially")
		"tube":
			info_label.add_text("Tube connecting above and below ground for people and cargo.")
		"seed":
			print("seed should be called specially")
		var ut:
			info_label.add_text("%s\nno description." % ut)
