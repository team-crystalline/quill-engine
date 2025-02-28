extends Area3D
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var timer = $Lifespan
@onready var blink_timer = $Blink
@onready var ring = get_tree()
@onready var hud := get_tree().get_first_node_in_group("HUD")
@onready var parent_node := self.get_parent()

func _ready() -> void:
	add_to_group("Player")
	timer.connect("timeout", Callable(self, "_on_Timer_timeout")) 
	await get_tree().create_timer(2).timeout
	blink_timer.connect("timeout", Callable(self, "_start_blinking"))
	
func disappear():
	parent_node.queue_free()

func _on_body_entered(body):
	print("Ouch!")
	if body.is_in_group("Player"):
		body.rings += 1
		var player_sound = body.get_node("RingSound")
		player_sound.play()
		disappear()

func _on_Timer_timeout():
	disappear()

func _start_blinking():
	parent_node.visible = false
	await get_tree().create_timer(.1).timeout
	parent_node.visible=true
