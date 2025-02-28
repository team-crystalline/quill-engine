extends Area3D
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var timer = $Timer # 10 seconds before deleting themselves.
@onready var hud := get_tree().get_first_node_in_group("HUD")

@onready var bling := $CollectBling
@onready var ring_model:= $RingModel
@onready var ring_box := $RingBox

func _ready() -> void:
	add_to_group("Player")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		bling.visible=true
		ring_box.visible = false
		ring_model.visible=false
		body.rings += 1
		# Play the sound on the player
		var player_sound = body.get_node("RingSound")  # Adjust the path if necessary
		player_sound.play()
		
		# Wait 0.8 seconds to go away.
		await get_tree().create_timer(.80).timeout
		queue_free()
