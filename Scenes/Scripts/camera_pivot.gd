extends Node3D

# Speed factor for smooth rotation
var rotation_speed = 3.0

# Target rotation angles (in radians)
var target_rotation = Vector3.ZERO

func _ready():
	# Initialize the target_rotation as current rotation, if desired.
	target_rotation = rotation

func orbit_camera(trigger_name):
	# Define your triggers with target angles (in degrees)
	var camera_triggers = {
		"trigger1": {"angle_x": 30, "angle_y": 0, "angle_z": 0},
		"trigger2": {"angle_x": 0,  "angle_y": 30, "angle_z": 0},
		"trigger3": {"angle_x": 0,  "angle_y": 30, "angle_z": 0},
		"trigger4": {"angle_x": 0,  "angle_y": 180, "angle_z": 0},
	}
	
	if trigger_name in camera_triggers:
		var trigger_data = camera_triggers[trigger_name]
		target_rotation.x += deg_to_rad(trigger_data["angle_x"])
		target_rotation.y += deg_to_rad(trigger_data["angle_y"])
		target_rotation.z += deg_to_rad(trigger_data["angle_z"])

func _process(delta):
	# Smoothly interpolate the pivot's rotation to the target rotation
	var new_x = lerp_angle(rotation.x, target_rotation.x, rotation_speed * delta)
	var new_y = lerp_angle(rotation.y, target_rotation.y, rotation_speed * delta)
	var new_z = lerp_angle(rotation.z, target_rotation.z, rotation_speed * delta)
	rotation = Vector3(new_x, new_y, rotation.z)
