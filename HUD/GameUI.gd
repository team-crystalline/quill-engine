extends Control
@onready var ringLabel = $RingsLabel
@onready var livesLabel = $LivesLabel
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("float")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var speed = player.current_speed
	ringLabel.text= "%d" % player.rings
	livesLabel.text= "%d" % player.lives
	$ModelStatsLabel.text = "Rotation:\n" + str(round(player.model.rotation * 100) / 100) + "\n\n" + "Velocity:\n" + str(round(player.velocity * 100) / 100) + "\n\n" +"Speed:\n" + str(round(player.current_speed * 100) / 100)
