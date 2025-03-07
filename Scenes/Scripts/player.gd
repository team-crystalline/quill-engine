extends CharacterBody3D

@onready var model = $Sonic
@onready var jumpModel = $JumpModel
# -------- Sonic's Properties ---------- #

@export_category("Player Properties")
@export var rings : int = 0
@export var lives : int = 3
@export_group("Ground Physics")
@export var stickiness_factor: float = 0.1  # Adjust this value to control how much Sonic sticks to the ground
@export var move_speed : float = 30
@export var follow_lerp_factor : float = 16
@export var jump_limit : int = 2
@export var current_speed : float = 0 # Current speed of the player
@export var acceleration_rate : float = 7 # Rate of acceleration
@export var deceleration_rate : float = 10 # Base rate of deceleration
@export var quick_stop_threshold : float = 0.1 # 10% of top speed
@export var top_speed : float = 100 # Fastest speed he can run without help + momentum
@export var max_speed : float = 200 # Fastest speed he can run with help + momentum
@export_group("Air Physics")
@export var jump_force : float = 1600
var jump_time = 0.0  # Time the jump button is held down
var is_jumping = false  # To track if the player is currently jumping
@export var min_jump_height : float = 2
@export var max_jump_height: float = 16
@export var air_acceleration_rate : float = 0
@export var air_deceleration_rate : float = 0
@export var air_top_speed : float = 60
var floor_normal = Vector3.UP
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

# -------------------------------------- #
# -------------------------------------- #
# Sounds
@onready var jump_sound = $JumpSound
# -------------------------------------- #
@onready var level := get_tree().get_first_node_in_group("Level")
@onready var spot_light = $SpotLight

# Spin Dash properties
var is_spinning: bool = false
var spin_dash_speed: float = 60 # Speed during Spin Dash
var spin_dash_duration: float = 1.0 # Duration of the Spin Dash
var spin_dash_timer: float = 0.0 # Timer for Spin Dash

func update_rotation(floor_normal: Vector3) -> void:
	var target_rotation_x = -floor_normal.z
	model.rotation.x = lerp_angle(model.rotation.x, target_rotation_x, 0.1)
	model.rotation.x = clamp(model.rotation.x, -PI / 4, PI / 4)

	var forward_direction = Vector3(sin(model.rotation.y), 0, cos(model.rotation.y)).normalized()
	var downhill_direction = Vector3(floor_normal.x, 0, floor_normal.z).normalized()

	# For going downhill
	if forward_direction.dot(downhill_direction) > 0:
		model.rotation.x = lerp_angle(model.rotation.x, downhill_direction.z, 0.1)

func _ready() -> void:
	print("Sonic's the name, speed's my game!")
	var level_groups = level.get_groups()
	if level.is_in_group("Morning") or level.is_in_group("Daytime") or level.is_in_group("Afternoon"):
		print("It's daytime. I don't need my spotlight.")
		spot_light.visible = false
	else:
		print("It's probably dark out. I should use my spotlight so the player can see me!")
		spot_light.visible = true 

func is_moving():
	return abs(velocity.z) > 0 || abs(velocity.x) > 0

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = max(velocity.y, -stickiness_factor)  # Prevent upward movement

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		is_jumping = true
		jump_time = 0.0

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		is_jumping = true
		jump_time = 0.0
		velocity.y = min_jump_height

	if Input.is_action_pressed("Jump") and is_jumping and velocity.y < max_jump_height:
		jump_time += get_physics_process_delta_time()
		velocity.y = min_jump_height + (max_jump_height - min_jump_height) * (jump_time / 0.5)

	if Input.is_action_just_released("Jump") or velocity.y >= max_jump_height:
		is_jumping = false

	# Handle Spin Dash
	if Input.is_action_just_pressed("SpinDash") and is_on_floor() and not is_spinning:
		print("Spin Dash!")
		is_spinning = true
		spin_dash_timer = spin_dash_duration
		velocity.x = direction.x * spin_dash_speed
		velocity.z = direction.z * spin_dash_speed
		current_speed = spin_dash_speed

	if is_spinning:
		spin_dash_timer -= delta
		if spin_dash_timer <= 0:
			is_spinning = false

	if is_moving():
		# Look in the right direction.
		var look_direction = Vector2(velocity.z, velocity.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta * 8)

	if direction:
		# Calculate target speed based on input
		var target_speed = direction.length() * move_speed
		var floor_normal = get_floor_normal()
		update_rotation(floor_normal)  # Pass the entire normal vector


		# Apply acceleration
		if is_on_floor():
			if target_speed > current_speed:
				current_speed = min(current_speed + acceleration_rate * delta, target_speed)
		else:
			# In the air, apply air acceleration
			if target_speed > current_speed:
				current_speed = min(current_speed + air_acceleration_rate * delta, target_speed)

		# Set the velocity based on the current speed
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		# Assuming deceleration_rate is defined and current_speed is initialized
		current_speed = current_speed - (deceleration_rate / 10)
		current_speed = max(current_speed, 0)

		# Decelerate velocity.x towards 0
		if velocity.x != 0:
			velocity.x -= sign(velocity.x) * (deceleration_rate / 10)
			# Clamp velocity.x to 0 if it goes below 0
			if (sign(velocity.x) != sign(velocity.x + (deceleration_rate / 10))):
				velocity.x = 0

		# Decelerate velocity.z towards 0
		if velocity.z != 0:
			velocity.z -= sign(velocity.z) * (deceleration_rate / 10)
			# Clamp velocity.z to 0 if it goes below 0
			if (sign(velocity.z) != sign(velocity.z + (deceleration_rate / 10))):
				velocity.z = 0
	# Move the character
	move_and_slide()
