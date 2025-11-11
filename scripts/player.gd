class_name Player
extends CharacterBody2D

const MOVE_SPEED := 150.0
var direction := Vector2.ZERO
var cardinal_dir := Vector2.DOWN
var state := "idle"
var can_move := true

@onready var anim := $AnimationPlayer

func _ready():
	_update_anim()

func _process(_delta):
	if not can_move:
		direction = Vector2.ZERO
		_set_state()
		_update_anim()
		return

	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	if _set_state() or _set_dir():
		_update_anim()

func _physics_process(_delta):
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = direction * MOVE_SPEED
	move_and_slide()

func _set_dir() -> bool:
	if direction == Vector2.ZERO: return false
	var new_dir = cardinal_dir
	if abs(direction.x) > 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif abs(direction.y) > 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
	if new_dir == cardinal_dir: return false
	cardinal_dir = new_dir
	return true

func _set_state() -> bool:
	var new_state = "idle" if direction == Vector2.ZERO else "walk"
	if new_state == state: return false
	state = new_state
	return true

func _update_anim():
	anim.play("%s_%s" % [state, _dir_to_str()])

func _dir_to_str() -> String:
	match cardinal_dir:
		Vector2.DOWN: return "down"
		Vector2.UP: return "up"
		Vector2.LEFT: return "left"
		_: return "right"
