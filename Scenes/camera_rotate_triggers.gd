extends Area3D

@export var rotate_angle: Vector3 = Vector3(5, 0, 0) # The angle to rotate the camera in degrees
@export var rotation_speed: int = 1 # Speed of rotation (1: slow, 2: medium, 3: fast, 0: instant)
@export var orbit_radius: float = 5.0 # Distance from the player
@export var camera_offset: Vector3 = Vector3(0, 2.973, 0) # Offset from the player position
var is_rotating: bool = false # Flag to control rotation
var camera: Camera3D # Declare camera variable at the class level
var current_angle: float = 0.0 # Current angle for orbiting

func _ready():
	self.connect("body_entered", Callable(self, "_on_body_entered"))
	self.connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	# Check if the body is in the "Player" group
	if body.is_in_group("Player"):
		print("Player touched me!")
		is_rotating = true
		# Get the camera reference here
		var gimbal = body.get_node("Gimbal") # Get the Gimbal node from the player
		if gimbal:
			camera = gimbal.get_node("Camera3D") # Get the Camera node under Gimbal
		# Start the orbiting as a coroutine
		orbit_camera(body)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		printe("Player left the area!")
		is_rotating = false

# Function to orbit the camera
func orbit_camera(player):
	while is_rotating:
		# Update the current angle based on the rotation speed and rotate_angle
		current_angle += rotate_angle.y * rotation_speed * 0.03 # Increment the angle (adjust speed as needed)
		
		# Convert the angle to radians for trigonometric functions
		var angle_rad = current_angle * (PI / 180) # Convert degrees to radians manually
		
		# Calculate the new camera position
		var offset = Vector3(cos(angle_rad), 0, sin(angle_rad)) * orbit_radius
		camera.global_transform.origin = player.global_transform.origin + offset + camera_offset
		
		# Ensure the camera is looking at the player
		camera.look_at(player.global_transform.origin + camera_offset, Vector3.UP)
		
		# Wait for a short duration before the next increment
		await get_tree().create_timer(0.03).timeout
