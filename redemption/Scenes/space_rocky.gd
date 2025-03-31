extends CharacterBody2D

const LEDGE_GRAB_COOLDOWN = 0.3  
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_LEDGE_GRABS = 5  

var gravity
var ledge_grab_count = 0  
var is_grabbing_ledge = false
var ledge_position = Vector2.ZERO
var dropping_through_platform = false
var ledge_grab_cooldown_timer = 0.0  

@onready var ledge_check_left = $LedgeCheckRayLeft
@onready var ledge_check_right = $LedgeCheckRayRight
@onready var collision_shape = $CollisionShape2D  # Make sure this references your collision shape

func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	ledge_check_left.enabled = true
	ledge_check_right.enabled = true

func _physics_process(delta):
	if ledge_grab_cooldown_timer > 0:
		ledge_grab_cooldown_timer -= delta  

	if is_grabbing_ledge:
		handle_ledge_hang()
	else:
		get_input(delta)
		if not is_on_floor() and not dropping_through_platform:
			velocity.y += gravity * delta  

	handle_ledge_grab()
	move_and_slide()

	# Reset ledge grab count when landing on solid ground
	if is_on_floor():
		ledge_grab_count = 0
		dropping_through_platform = false  

func get_input(delta):
	var direction = 0  # Default to no movement

	# Left & Right Movement
	if Input.is_action_pressed("Left"):
		direction = -1
	elif Input.is_action_pressed("Right"):
		direction = 1
	
	velocity.x = direction * SPEED  # Apply horizontal movement

	# Jumping
	if Input.is_action_just_pressed("Jump"):
		if is_grabbing_ledge:
			is_grabbing_ledge = false
			velocity.y = JUMP_VELOCITY  
			ledge_grab_cooldown_timer = LEDGE_GRAB_COOLDOWN  
		elif is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Drop-through platform mechanic (only activates on one-way platforms)
	if Input.is_action_just_pressed("Down") and is_on_floor():
		var collision = get_last_slide_collision()
		if collision and collision.get_collider() and collision.get_collider().is_in_group("one_way_platform"):
			drop_through_platform()

func drop_through_platform():
	if not dropping_through_platform:
		dropping_through_platform = true
		collision_shape.set_deferred("disabled", true)  # Disable collision to pass through
		get_tree().create_timer(0.2).timeout.connect(_enable_collision)  # Restore collision after short delay

# Re-enable collision after drop-through
func _enable_collision():
	collision_shape.set_deferred("disabled", false)  
	dropping_through_platform = false  

func handle_ledge_grab():
	if is_grabbing_ledge or ledge_grab_cooldown_timer > 0:
		return  

	if ledge_grab_count >= MAX_LEDGE_GRABS:
		return  

	var can_grab_left = ledge_check_left.is_colliding()
	var can_grab_right = ledge_check_right.is_colliding()

	if can_grab_left or can_grab_right:
		is_grabbing_ledge = true
		velocity = Vector2.ZERO  
		ledge_position = position
		position.y -= 5  
		ledge_grab_count += 1  

func handle_ledge_hang():
	velocity = Vector2.ZERO  

	if Input.is_action_just_pressed("Jump"):
		is_grabbing_ledge = false
		velocity.y = JUMP_VELOCITY  
		ledge_grab_cooldown_timer = LEDGE_GRAB_COOLDOWN  

	if Input.is_action_just_pressed("Left") or Input.is_action_just_pressed("Right"):
		is_grabbing_ledge = false  
		ledge_grab_cooldown_timer = LEDGE_GRAB_COOLDOWN  
