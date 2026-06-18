extends AudioStreamPlayer2D
@onready var soundBtn = %SoundButton

# Called when the node enters the scene tree for the first time.
func _ready():
	play()
	 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sound_button_pressed() -> void:
	stream_paused = !stream_paused
	if stream_paused:
		soundBtn.text = "Music Off"
	else:
		soundBtn.text = "Music On"
