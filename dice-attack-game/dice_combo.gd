extends Node
class_name DiceCombo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func resolve(damage_count, health_count, damage_plus_count):

	if health_count >= 3:
		return {
			"name": "Heal",
			"damage": 0,
			"heal": 25
		}

	if damage_plus_count >= 2:
		return {
			"name": "Damage Pluls",
			"damage": 50,
			"heal": 0
		}

	if health_count >= 2 and damage_count >= 1 and damage_plus_count >= 1:
		return {
			"name": "Vampire Bite",
			"damage": 25,
			"heal": 25
		}

	if damage_count >= 2:
		return {
			"name": "Damage",
			"damage": 25,
			"heal": 0
		}

	return {
		"name": "Miss",
		"damage": 0,
		"heal": 0
	}
