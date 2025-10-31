class_name Player extends CharacterBody2D

# --- Movement Variables ---
const MOVE_SPEED: float = 500.0
var direction : Vector2 = Vector2.ZERO      # Holds input direction (normalized)

# --- Animation/State Variables ---
var cardinal_direction : Vector2 = Vector2.DOWN
var state : String = "idle"

# --- Onready References ---
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D


func _ready():
	UpdateAnimation()
	
# --------------------------------------------------------------------------
# 1. INPUT HANDLING AND ANIMATION STATE (Runs every frame)
# --------------------------------------------------------------------------
func _process( delta ):
	
	# Use Godot's built-in input actions (ui_*)
	var raw_input_vector = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)
	
	direction = raw_input_vector.normalized()
	
	# Update character state and direction for animation
	if SetState() or SetDirection():
		UpdateAnimation()
	
# --------------------------------------------------------------------------
# 2. PHYSICS MOVEMENT (Runs at fixed physics rate)
# --------------------------------------------------------------------------
func _physics_process( delta ) :
	
	velocity = direction * MOVE_SPEED
	move_and_slide()

# --------------------------------------------------------------------------
# 3. STATE AND ANIMATION LOGIC
# --------------------------------------------------------------------------

func SetDirection() -> bool:
	# If input is zero, we don't change the cardinal direction, 
	# we just let the state change to "idle" (handled in SetState()).
	if direction == Vector2.ZERO:
		return false
		
	var new_dir : Vector2 = cardinal_direction
	
	# Determine the new cardinal direction
	
	# 1. Prioritize Left/Right movement (includes diagonals like up-left, down-right)
	if abs(direction.x) > 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
		
	# 2. If there is NO horizontal movement (i.e., purely vertical input), 
	#    set direction to Up/Down.
	elif abs(direction.y) > 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN

	if new_dir == cardinal_direction:
		return false
		
	cardinal_direction = new_dir
	
	return true
	
func SetState() -> bool:
	# Note: This function runs even if direction == ZERO, ensuring it switches to "idle"
	var new_state : String = "idle" if direction == Vector2.ZERO else "walk"
	if new_state == state:
		return false
	state = new_state
	return true
	
func UpdateAnimation() -> void:
	animation_player.play(state + "_" + AnimDirection())

func AnimDirection() -> String :
	# This returns the animation suffix based on the current cardinal direction
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	else : # Vector2.RIGHT
		return "right"
