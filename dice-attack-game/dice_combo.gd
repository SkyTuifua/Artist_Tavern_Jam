class_name DiceCombo

enum DICE_COMBOS {HEAL, DAMAGE_PLUS, VAMPIRE_BITE, DAMAGE}

class dice_combo_info: ##struct for dice combos information and what it does.
	var name : String
	var damage : float
	var health : float
	var combination : Array[Side.SIDE_COLORS]
##What combos the player has with their current set.
static func translate_dice_combo(dice_combo : Array[Side.SIDE_COLORS])->void:
	pass

##Returns info about what a dice_combo does. Use this to make new dice combos or balance old ones.
static func get_dice_combo_info(combo : DICE_COMBOS)->dice_combo_info:
	print(combo)
	var dci := dice_combo_info.new()
	match combo:
		DICE_COMBOS.HEAL:
			dci.name = "Heal"
			dci.damage = 0
			dci.health = 25
			dci.combination = [Side.SIDE_COLORS.BASE_HEALTH,Side.SIDE_COLORS.BASE_HEALTH,Side.SIDE_COLORS.BASE_HEALTH]
			return dci
		DICE_COMBOS.DAMAGE_PLUS:
			dci.name = "Damage Plus"
			dci.damage = 50
			dci.health = 0
			dci.combination = [Side.SIDE_COLORS.DAMAGE_PLUS,Side.SIDE_COLORS.DAMAGE_PLUS]
			return dci
		DICE_COMBOS.VAMPIRE_BITE:
			dci.name = "Vampire Bite"
			dci.damage = 25
			dci.health = 25
			dci.combination = [Side.SIDE_COLORS.BASE_DAMAGE, Side.SIDE_COLORS.BASE_DAMAGE, Side.SIDE_COLORS.BASE_HEALTH, Side.SIDE_COLORS.BASE_HEALTH]
			return dci
		DICE_COMBOS.DAMAGE:
			dci.name = "Damage"
			dci.damage = 25
			dci.health = 0
			dci.combination = [Side.SIDE_COLORS.BASE_DAMAGE,Side.SIDE_COLORS.BASE_DAMAGE]
			return dci
	return dci

static func has_combo(roll : Array[Side.SIDE_COLORS], combo : DiceCombo.DICE_COMBOS):
	var checker : Array[Side.SIDE_COLORS] = get_dice_combo_info(combo).combination.duplicate()
	for i in roll:
		if checker.has(i):
			checker.erase(i)
		if checker.is_empty():
			return true
	return false
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
