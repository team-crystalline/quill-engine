extends Control
@onready var ringLabel = $RingsLabel
@onready var livesLabel = $LivesLabel
@onready var player := get_tree().get_first_node_in_group("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# coinsLabel.text = "x %d" % GameManager.score
	ringLabel.text= "%d" % player.rings
	livesLabel.text= "%d" % player.lives
