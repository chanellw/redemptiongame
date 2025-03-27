extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var jump_count = 0
var max_jump = 2
var buttons_pressed : String = ""
var AttackPoints = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Count of how many jumps have been done so far. 
	if is_on_floor():
		jump_count = 0
		
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and jump_count < max_jump:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _unhandled_input(event: InputEvent) -> void:
		# Handle light attack.
	if Input.is_action_just_pressed("Light"):
		buttons_pressed += "Light"
	# Handle medium attack.
	if Input.is_action_just_pressed("Medium"):
		buttons_pressed += "Medium"
	# Handle heavy attack.
	if Input.is_action_just_pressed("Heavy"):
		buttons_pressed += "Heavy"
		
		
func _combos():
	if "upLight" in buttons_pressed:
		$AnimatedSprite2D2.play("attack")
		buttons_pressed = ""
			
	if "leftrightleftright" in buttons_pressed:
		$AnimatedSprite2D2.play("attack2")
		buttons_pressed = ""
	
	move_and_slide()
