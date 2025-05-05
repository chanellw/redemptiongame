extends CharacterBody2D

const LEDGE_GRAB_COOLDOWN = 0.1  
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_LEDGE_GRABS = 5  
const FAST_FALL_MULTIPLIER = 2.5
const WALL_GRAB_TIMEOUT = 0.7
const WALL_GRAB_DELAY = 0.15

const DASH_SPEED = 600.0
const DASH_DURATION = 0.15
const AIR_DASH_SPEED = 450.0
const AIR_UPWARD_DASH_MULTIPLIER = 0.8

var gravity
var ledge_grab_count = 0  
var is_grabbing_wall = false
var wall_position = Vector2.ZERO
var dropping_through_platform = false
var ledge_grab_cooldown_timer = 0.0  
var is_fast_falling = false  
var can_double_jump = true
var wall_grab_timer = 0.0
var wall_grab_delay_timer = 0.0

var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector2.ZERO
var can_air_dash = true

var combos = {"3 hit combo" : ["Light", "Light", "Light"], ""}
# Buffer to store recent inputs
var input_buffer = []
var buffer_time = 0.5 # seconds
var max_buffer = 10
var input_timer = 0.0
var combo_actions = { "3 hit combo": "Light_Attack"}

@onready var ledge_check_left = $LedgeCheckRayLeft
@onready var ledge_check_right = $LedgeCheckRayRight
@onready var collision_shape = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if ledge_grab_cooldown_timer > 0:
		ledge_grab_cooldown_timer -= delta
	if wall_grab_delay_timer > 0:
		wall_grab_delay_timer -= delta

	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction
		if dash_timer <= 0:
			is_dashing = false
	else:
		if is_grabbing_wall:
			handle_wall_hang()
			wall_grab_timer += delta
			if wall_grab_timer > WALL_GRAB_TIMEOUT:
				release_wall()
		else:
			get_input()
			apply_gravity(delta)

	handle_wall_grab()
	move_and_slide()

	if is_on_floor():
		ledge_grab_count = 0
		dropping_through_platform = false  
		is_fast_falling = false  
		can_double_jump = true
		can_air_dash = true
		wall_grab_timer = 0.0
		wall_grab_delay_timer = 0.0

func get_input():
	var direction = 0
	if Input.is_action_pressed("Left"):
		direction = -1
	elif Input.is_action_pressed("Right"):
		direction = 1
	velocity.x = direction * SPEED

	# Walking animation
	if direction != 0:
		animated_sprite.play("Walk")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.stop()

	if Input.is_action_just_pressed("Jump"):
		if is_grabbing_wall:
			release_wall()
			velocity.y = JUMP_VELOCITY
			ledge_grab_cooldown_timer = LEDGE_GRAB_COOLDOWN
		elif is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false

	if Input.is_action_pressed("Down") and not is_on_floor():
		is_fast_falling = true
	else:
		is_fast_falling = false  

	if Input.is_action_just_pressed("Down") and is_on_floor():
		var collision = get_last_slide_collision()
		if collision and collision.get_collider() and collision.get_collider().is_in_group("one_way_platform"):
			drop_through_platform()

	# DASH INPUT
	if Input.is_action_just_pressed("Dash") and not is_dashing:
		var dash_vec = Vector2.ZERO
		var left = Input.is_action_pressed("Left")
		var right = Input.is_action_pressed("Right")
		var up = Input.is_action_pressed("Up")
		var down = Input.is_action_pressed("Down")

		if is_on_floor():
			if left:
				dash_vec.x = -1
			elif right:
				dash_vec.x = 1
			if dash_vec != Vector2.ZERO:
				start_dash(dash_vec.normalized() * DASH_SPEED)
		elif can_air_dash:
			if left:
				dash_vec.x -= 1
			if right:
				dash_vec.x += 1
			if up:
				dash_vec.y -= 1
			if down:
				dash_vec.y += 1

			if dash_vec != Vector2.ZERO:
				dash_vec = dash_vec.normalized()

				# Reduce vertical power if dashing upward
				if dash_vec.y < 0:
					dash_vec.y *= AIR_UPWARD_DASH_MULTIPLIER

				start_dash(dash_vec * AIR_DASH_SPEED)
				can_air_dash = false

func start_dash(direction: Vector2):
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_direction = direction

func apply_gravity(delta):
	if not is_on_floor() and not dropping_through_platform:
		if is_fast_falling:
			velocity.y += gravity * FAST_FALL_MULTIPLIER * delta
		else:
			velocity.y += gravity * delta

func drop_through_platform():
	if not dropping_through_platform:
		dropping_through_platform = true
		collision_shape.set_deferred("disabled", true)  
		get_tree().create_timer(0.2).timeout.connect(_enable_collision)

func _enable_collision():
	collision_shape.set_deferred("disabled", false)
	dropping_through_platform = false

func handle_wall_grab():
	if is_grabbing_wall or ledge_grab_cooldown_timer > 0 or wall_grab_delay_timer > 0:
		return

	if ledge_grab_count >= MAX_LEDGE_GRABS:
		return

	var can_grab_left = ledge_check_left.is_colliding()
	var can_grab_right = ledge_check_right.is_colliding()

	if (can_grab_left and Input.is_action_pressed("Left")) or (can_grab_right and Input.is_action_pressed("Right")):
		is_grabbing_wall = true
		velocity = Vector2.ZERO
		wall_position = position
		position.y -= 5
		ledge_grab_count += 1
		can_double_jump = true
		wall_grab_timer = 0.0

func handle_wall_hang():
	velocity = Vector2.ZERO

	if Input.is_action_just_pressed("Jump"):
		release_wall()
		velocity.y = JUMP_VELOCITY
		ledge_grab_cooldown_timer = LEDGE_GRAB_COOLDOWN

	if Input.is_action_just_pressed("Left") or Input.is_action_just_pressed("Right"):
		release_wall()
		ledge_grab_cooldown_timer = LEDGE_GRAB_COOLDOWN

func release_wall():
	is_grabbing_wall = false
	wall_grab_timer = 0.0
	wall_grab_delay_timer = WALL_GRAB_DELAY


func _process(delta):
	handle_input()
	input_timer += delta
	if input_timer > buffer_time:
		if input_buffer.size() > 0:
			input_buffer.pop_front()
		input_timer = 0.0

func handle_input():
	# Map input to strings
	if Input.is_action_just_pressed("Light"):
		register_input("Light")
	if Input.is_action_just_pressed("Medium"):
		register_input("Medium")

func register_input(input):
	input_buffer.append(input)
	if input_buffer.size() > max_buffer:
		input_buffer.pop_front()
	check_combos()

func check_combos():
	for name in combos.keys():
		var sequence = combos[name]
		if is_combo_match(sequence):
			print("Combo matched: ", name)
			perform_combo(name)
			input_buffer.clear() # Reset after successful combo
			break

func is_combo_match(sequence):
	if input_buffer.size() < sequence.size():
		return false
	for i in range(sequence.size()):
		if input_buffer[input_buffer.size() - sequence.size() + i] != sequence[i]:
			return false
		return true

func perform_combo(combo_name):
	var action = combo_actions.get(combo_name, null)
	if action:
		$AnimatedSprite2D.play("Light_Attack")
