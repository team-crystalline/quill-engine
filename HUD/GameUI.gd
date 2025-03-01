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
	#print(player.velocity)
	$SpeedLabel.text = "Velocity: \n(%s, %s)" % [str(player.velocity.x), str(player.velocity.y)]
