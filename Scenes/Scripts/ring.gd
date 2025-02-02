extends Area3D
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var timer = $Timer # 10 seconds before deleting themselves.
@onready var hud := get_tree().get_first_node_in_group("HUD")

func _ready() -> void:
	add_to_group("Player")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.rings += 1
		# Play the sound on the player
		var player_sound = body.get_node("RingSound")  # Adjust the path if necessary
		player_sound.play()
		queue_free()
