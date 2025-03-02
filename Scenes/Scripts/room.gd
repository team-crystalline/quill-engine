extends Node3D
"""
This script is to run basic functionality of each level. Currently, it establishes spawn points.
Attach this script to the *root node* of your level.
"""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var level_name = get_meta("LevelName") # Retrieve the metadata
	print("Welcome to %s." % level_name) # Concatenate and print the level name
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
