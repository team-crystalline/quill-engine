extends Label

# Variables to keep track of time
var elapsed_time: float = 0.0
var timer_running: bool = false

# Called when the node enters the scene tree for the first time
func _ready():
	# Start the timer
	timer_running = true

# Called every frame
func _process(delta: float) -> void:
	if timer_running:
		# Increment the elapsed time by the delta time
		elapsed_time += delta
		
		# Format the time
		update_timer_display()

# Function to update the timer display
func update_timer_display() -> void:
	var total_milliseconds: int = int(elapsed_time * 1000)
	var minutes: int = total_milliseconds / 60000
	var seconds: int = (total_milliseconds % 60000) / 1000
	var milliseconds: int = total_milliseconds % 1000 / 10  # Get the first two digits of milliseconds

	# Format the string as mm:ss:ms
	#text = sprintf("%02d:%02d:%02d", minutes, seconds, milliseconds)
	text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
