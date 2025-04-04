extends CharacterBody2D

const LEDGE_GRAB_COOLDOWN = 0.3  
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_LEDGE_GRABS = 5  
const FAST_FALL_MULTIPLIER = 2.5  # Gravity multiplier for fast fall

var gravity
var ledge_grab_count = 0  
var is_grabbing_ledge = false
var ledge_position = Vector2.ZERO
var dropping_through_platform = false
var ledge_grab_cooldown_timer = 0.0  
var is_fast_falling = false  
var can_double_jump = true  # <-- new


@onready var ledge_check_left = $LedgeCheckRayLeft
@onready var ledge_check_right = $LedgeCheckRayRight
@onready var collision_shape = $CollisionShape2D  


	else:
		get_input(delta)
		apply_gravity(delta)


