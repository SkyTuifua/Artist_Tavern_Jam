extends Node3D

enum CoinResult {
	HEADS,
	TAILS
}

var current_coin_result : CoinResult

@onready var animation_player: AnimationPlayer = $CoinAnimation


func start_coin_flow() -> void:
	animation_player.play("coin_rise")
	flip_coin()


func flip_coin() -> void:

	if randf() < 0.5:
		current_coin_result = CoinResult.HEADS
		animation_player.play("coin_heads")
	else:
		current_coin_result = CoinResult.TAILS
		animation_player.play("coin_tails")

	# Wait until the flip animation is done
	await animation_player.animation_finished
	animation_player.play("coin_disappear")
