extends Node3D
"""
This script is to run basic functionality of each level. Currently, it establishes spawn points.
Attach this script to the *root node* of your level.
"""
func _ready() -> void:
	var level_name = get_meta("LevelName")
	var level_mission = get_meta("Mission")
	print("Welcome to %s." % level_name)
	print("Mission: %s" % level_mission)
