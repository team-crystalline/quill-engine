extends Area3D
@onready var player := get_tree().get_first_node_in_group("Player")
@export var strength : int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	#print("Ouch!")
	if body.is_in_group("Player"):
		body.velocity.y += 20 * strength
