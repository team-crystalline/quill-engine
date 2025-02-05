extends CharacterBody3D

@onready var model = $Sonic
@onready var jumpModel = $JumpModel

# -------- Sonic's Properties ---------- #

@export_category("Sonic's Properties")
@export var rings : int = 0
@export var lives : int = 3
@export_group("Ground Physics")
@export var stickiness_factor: float = 0.1  # Adjust this value to control how much Sonic sticks to the ground
@export var move_speed : float = 30
@export var follow_lerp_factor : float = 16
@export var jump_limit : int = 2
@export var current_speed : float = 0 # Current speed of the player
@export var acceleration_rate : float = 7 # Rate of acceleration
@export var deceleration_rate : float = 20 # Base rate of deceleration
@export var quick_stop_threshold : float = 0.1 # 10% of top speed
@export var top_speed : float = 100 # Fastest speed he can run without help + momentum
@export var max_speed : float = 200 # Fastest speed he can run with help + momentum
@export_group("Air Physics")
@export var jump_force : float = 16
@export var min_jump_height : float = 2
@export var max_jump_height: float = 10
@export var air_acceleration_rate : float = 0
@export var air_deceleration_rate : float = 0
@export var air_top_speed : float = 300
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
var spin_dash_speed: float = 150 # Speed during Spin Dash
var spin_dash_duration: float = 1.0 # Duration of the Spin Dash
var spin_dash_timer: float = 0.0 # Timer for Spin Dash

func update_rotation(axis: int, floor_normal_value: float) -> void:
	# Check if the slope normal for the given axis is 0
	if floor_normal_value == 0:
		# Snap back to upright position
		match axis:
			0: model.rotation.x = 0  # Upright for x-axis
			1: model.rotation.y = 0  # Upright for y-axis
			2: model.rotation.z = 0  # Upright for z-axis
	else:
		# Update rotation with clamping
		match axis:
			# + floor_normal_value
			0: model.rotation.x = floor_normal_value
			1: model.rotation.y = floor_normal_value # Should be unused unless wall running?
			2: model.rotation.z = floor_normal_value
	print("Model should be rotated:", model.rotation)

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
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		model.visible=false
		jumpModel.visible=true
	else:
		model.visible = true
		jumpModel.visible =false
		# Apply stickiness when on the floor
		if velocity.y < 0:  # Only apply stickiness if falling
			velocity.y = max(velocity.y, -stickiness_factor)  # Limit downward velocity

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = max_jump_height
		jump_sound.play()
	
		# Handle Spin Dash
	if Input.is_action_just_pressed("SpinDash") and is_on_floor() and not is_spinning:
		print("Spin Dash!")
		is_spinning = true
		spin_dash_timer = spin_dash_duration
		velocity.x = direction.x * spin_dash_speed
		velocity.z = direction.z * spin_dash_speed

	if is_spinning:
		spin_dash_timer -= delta
		if spin_dash_timer <= 0:
			is_spinning = false


	if is_moving():
		# Look in the right direction.
		var look_direction = Vector2(velocity.z, velocity.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta * 8)
	else:
		# Reset current speed. Momentum must be built up again.
		current_speed = 0

	if direction:
		# Calculate target speed based on input
		var target_speed = direction.length() * move_speed
		var floor_normal = get_floor_normal()
		update_rotation(0, floor_normal.x)  # X-axis
		update_rotation(2, floor_normal.z)  # Z-axis

		# Apply acceleration
		if is_on_floor():
			if target_speed > current_speed:
				current_speed = min(current_speed + acceleration_rate * delta, target_speed)
			else:
				# Adjust deceleration based on current speed
				var effective_deceleration = deceleration_rate * (current_speed / top_speed)
				if current_speed < quick_stop_threshold * top_speed:
					# Apply a higher deceleration rate for quick stops
					effective_deceleration *= 2 # Adjust this multiplier as needed
				current_speed = max(current_speed - effective_deceleration * delta, target_speed)
		else:
			# In the air, apply air acceleration
			if target_speed > current_speed:
				current_speed = min(current_speed + air_acceleration_rate * delta, target_speed)

		# Set the velocity based on the current speed
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		# Decelerate to a stop when no input is given
		if is_on_floor():
			# Adjust deceleration based on current speed
			var effective_deceleration = deceleration_rate * (current_speed / top_speed)
			if current_speed < quick_stop_threshold * top_speed:
				# Apply a higher deceleration rate for quick stops
				effective_deceleration *= .1 # Adjust this multiplier as needed
			current_speed = max(current_speed - effective_deceleration * delta, 0)
		else:
			# In the air, apply air deceleration
			current_speed = move_toward(current_speed, 0, air_deceleration_rate * delta)

	# Update velocity based on current speed
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	move_and_slide()
