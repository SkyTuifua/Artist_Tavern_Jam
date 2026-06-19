extends Node3D

enum CoinResult {
	HEADS,
	TAILS
}

var current_coin_result : CoinResult
signal coin_finished
signal coin_result(result)

@onready var animation_player: AnimationPlayer = $CoinAnimation


func start_coin_flow() -> void:
	animation_player.play("coin_rise")
	await animation_player.animation_finished
	flip_coin()


func flip_coin() -> void:

	if randf() < 0.5:
		current_coin_result = CoinResult.HEADS
		animation_player.play("coin_heads")
	else:
		current_coin_result = CoinResult.TAILS
		animation_player.play("coin_tails")
		rotation_degrees.x = 180

	# Wait until the flip animation is done
	await animation_player.animation_finished
	animation_player.play("coin_disappear")
	rotation_degrees = Vector3.ZERO
	coin_result.emit(current_coin_result)
	coin_finished.emit()
