extends Camera2D

const ZOOM_SPEED := Vector2(0.1, 0.1)
const MOVE_SPEED := 128

const UP := Vector2(128, -64)
const DOWN := Vector2(-129, 64)
const RIGHT := Vector2(128, 64)
const LEFT := Vector2(-128, -64)


func _process(_delta: float) -> void:
	var mod = 5 if Input.is_action_pressed("shift") else 1
	if Input.is_action_just_pressed("left"):
		position += LEFT * mod
	elif Input.is_action_just_pressed("right"):
		position += RIGHT * mod
	elif Input.is_action_just_pressed("up"):
		position += UP * mod
	elif Input.is_action_just_pressed("down"):
		position += DOWN * mod
