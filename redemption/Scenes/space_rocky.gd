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


	else:
		get_input(delta)
		if not is_on_floor() and not dropping_through_platform:
			velocity.y += gravity * delta  

