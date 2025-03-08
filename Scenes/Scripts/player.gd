extends CharacterBody3D

@onready var model = $Sonic
@onready var jumpModel = $JumpModel
# -------- Sonic's Properties ---------- #

@export_category("Player Properties")
@export var rings : int = 0
@export var lives : int = 3
@export_group("Ground Physics")
@export var stickiness_factor: float = 0.1  # Adjust this value to control how much Sonic sticks to the ground
@export var move_speed : float = 20
@export var follow_lerp_factor : float = 16
@export var jump_limit : int = 2
@export var current_speed : float = 0 # Current speed of the player
@export var acceleration_rate : float = 7 # Rate of acceleration
@export var deceleration_rate : float = 10 # Base rate of deceleration
@export var quick_stop_threshold : float = 0.1 # 10% of top speed
@export var top_speed : float = 30 # Fastest speed he can run without help + momentum
@export var max_speed : float = 80 # Fastest speed he can run with help + momentum
@export var drag_factor : float = .5  # Adjust this value based on testing
@export_group("Air Physics")
@export var jump_force : float = 1600
var jump_time = 0.0  # Time the jump button is held down
var is_jumping = false  # To track if the player is currently jumping
@export var min_jump_height : float = 8
@export var max_jump_height: float = 32
@export var air_acceleration_rate : float = 0
@export var air_deceleration_rate : float = 0
@export var air_top_speed : float = 60
var floor_normal = Vector3.UP
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2
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

func is_downhill(forward_direction: Vector3, downhill_direction: Vector3):
	if forward_direction.dot(downhill_direction) > 0:
		return true
	else:
		return false
		
func is_uphill(forward_direction: Vector3, floor_normal: Vector3) -> bool:
	return forward_direction.dot(floor_normal) < 0

# Function to check if the surface is flat
func is_flat_surface() -> bool:
	var floor_normal = get_floor_normal()
	# Check if the Y component is close to 1 and X and Z components are close to 0
	return abs(floor_normal.y) > 0.9 and abs(floor_normal.x) < 0.1 and abs(floor_normal.z) < 0.1

func update_rotation(floor_normal: Vector3) -> void:
	var target_rotation_x = -floor_normal.z
	model.rotation.x = lerp_angle(model.rotation.x, target_rotation_x, 0.1)
	model.rotation.x = clamp(model.rotation.x, -PI / 4, PI / 4)

	var forward_direction = Vector3(sin(model.rotation.y), 0, cos(model.rotation.y)).normalized()
	var downhill_direction = Vector3(floor_normal.x, 0, floor_normal.z).normalized()

	# For going downhill
	if is_downhill(forward_direction, downhill_direction):
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
	# Normalize the input direction
	input_dir = input_dir.normalized()
	var camera = $CameraPivot/Camera3D
	var camera_basis = camera.global_transform.basis
	# This moves the player based on camera rotation.
	var direction = (camera_basis.x * input_dir.x + camera_basis.z * input_dir.y).normalized()
	
	# Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = max(velocity.y, -stickiness_factor)  # Prevent upward movement
		model.visible= true
		jumpModel.visible = false

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		is_jumping = true
		jump_time = 0.0
		velocity.y = min_jump_height
		model.visible= false
		jumpModel.visible = true

	if Input.is_action_pressed("Jump") and is_jumping and velocity.y < max_jump_height:
		jump_time += get_physics_process_delta_time()
		velocity.y = min_jump_height + (max_jump_height - min_jump_height) * (jump_time / 0.1)

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
			
	# Special Action 1
	if Input.is_action_just_pressed("SpecialMove1"):
		$CameraPivot.orbit_camera("trigger1")

	if is_moving():
		# Look in the right direction.
		var look_direction = Vector2(velocity.z, velocity.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta * 8)

	if direction:
		var floor_normal = get_floor_normal()  # Get the floor normal first
		var forward_direction = Vector3(sin(model.rotation.y), 0, cos(model.rotation.y)).normalized()
		var downhill_direction = Vector3(floor_normal.x, 0, floor_normal.z).normalized()

		var target_speed = direction.length() * move_speed
		
		if is_downhill(forward_direction, downhill_direction) and is_moving():
			# Increase target speed when going downhill
			target_speed = direction.length() * max_speed
		elif is_uphill(forward_direction, floor_normal) and is_moving():
			# Calculate the angle of the slope
			var angle = forward_direction.angle_to(floor_normal)
			var slope_factor = clamp(angle / (PI / 2), 0, 1)  # Normalize the angle to a value between 0 and 1
			
			# Apply drag based on slope angle and current speed
			var drag_amount = slope_factor * drag_factor * current_speed * delta
			current_speed = max(current_speed - drag_amount, top_speed * 0.45)  # Ensure minimum speed is 45% of top speed

			# Debugging output
			print("Uphill: Angle: ", angle, " Slope Factor: ", slope_factor, " Drag Amount: ", drag_amount, " Current Speed: ", current_speed)

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

		# Update rotation based on the floor normal
		update_rotation(floor_normal)

	else:
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
