extends CharacterBody2D

# Constants for movement
const MAX_SPEED = 200
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var drop_through = false

# Store reference to CollisionShape2D for disabling when dropping through
@onready var collision_shape = $CollisionShape2D  # Ensure this node exists
@onready var current_floor = null  # Tracks the floor the player is standing on

func _physics_process(delta):
	player_movement(delta)

func get_input(delta):
	var input = Vector2.ZERO  # Reset input each frame

	# Left & Right movement
	input.x = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))

	# Apply gravity always when not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# Check if the current floor is a one-way platform
	if is_on_floor():
		var collision = get_last_slide_collision()
		if collision:  # Ensure it's not null before accessing properties
			current_floor = collision.get_collider()

	# Jumping mechanic
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Drop-through platform mechanic (only activates on one-way platforms)
	if Input.is_action_just_pressed("Down") and is_on_floor() and current_floor and current_floor.is_in_group("one_way_platform"):
		drop_through = true
		collision_shape.set_deferred("disabled", true)  # Disable collision to pass through
		get_tree().create_timer(0.2).timeout.connect(_enable_collision)  # Restore collision after short delay

	return input

# Re-enable collision after drop-through
func _enable_collision():
	collision_shape.set_deferred("disabled", false)  # Re-enable collision
	drop_through = false  # Reset drop-through state

func player_movement(delta):
	var input = get_input(delta)

	# Horizontal movement
	if input.x != 0:
		velocity.x = input.x * MAX_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MAX_SPEED)

	# Apply velocity to character
	move_and_slide()
