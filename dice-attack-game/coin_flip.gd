extends Node3D

enum CoinResult {
	HEADS,
	TAILS
}

var start_position : Vector3
var start_rotation : Vector3
var current_coin_result : CoinResult
signal coin_finished
signal coin_result(result)

@onready var animation_player: AnimationPlayer = $CoinAnimation
@onready var coin_accepted: AudioStreamPlayer2D = %coin_accept
@onready var coin_rejected: AudioStreamPlayer2D = %coin_reject

func _ready():
	start_position = position
	start_rotation = rotation

func start_coin_flow() -> void:
	position = start_position
	rotation_degrees = start_rotation
	animation_player.play("coin_rise")
	print("rise")
	await animation_player.animation_finished
	flip_coin()


func flip_coin() -> void:
	print("flip")
	if randf() < 0.5:
		current_coin_result = CoinResult.HEADS
		animation_player.play("coin_heads")
		await animation_player.animation_finished
		coin_accepted.play()
		animation_player.play("coin_heads_disappear")
	else:
		current_coin_result = CoinResult.TAILS
		animation_player.play("coin_tails")
		await animation_player.animation_finished
		coin_rejected.play()
		animation_player.play("coin_tails_disappear")

	# Wait until the flip animation is done
	await animation_player.animation_finished
	animation_player.play("RESET")
	await animation_player.animation_finished
	coin_result.emit(current_coin_result)
	coin_finished.emit()
