extends VBoxContainer
class_name Entries_Container

signal entry_chosen(combo : DiceCombo.DICE_COMBOS)

func create_entries(player_roll : Array[Side.SIDE_COLORS]) -> void:

	for combo in DiceCombo.DICE_COMBOS.values():
		var typed_combo := combo as DiceCombo.DICE_COMBOS
		if typed_combo == null:
			continue
		var entry : Dice_Combo_Entry = preload("res://UI/dice_combo_entry.tscn").instantiate()
		add_child(entry)
		setup_combo_entry(entry, combo, player_roll)

	filter_weaker_combos()
		
func clear_entries()->void:
	for i in get_children():
		i.queue_free()
		
func handle_entry_button_pressed(combo : DiceCombo.DICE_COMBOS)->void:
	entry_chosen.emit(combo)
	clear_entries()
	
func setup_combo_entry(entry : Dice_Combo_Entry, combo : DiceCombo.DICE_COMBOS, player_roll : Array[Side.SIDE_COLORS])->void:
	entry.apply_info(combo)
	entry.set_can_use_ability(DiceCombo.has_combo(player_roll, combo))
	entry.entry_chosen.connect(handle_entry_button_pressed)
	#sort abilities that player can use to the top.
	const TOP : int = 0
	if entry.can_use_ability:
		entry.get_parent().move_child(entry,TOP)
	else:
		entry.visible = false

func filter_weaker_combos() -> void:
	var strongest := {}

	for child in get_children():
		var entry := child as Dice_Combo_Entry
		if entry == null:
			continue
		if !entry.can_use_ability:
			continue

		var info = DiceCombo.get_dice_combo_info(entry.current_dc)
		var type = info.ability_type

		var power := 0.0

		match type:
			DiceCombo.ABILITY_TYPE.HEAL:
				power = info.health

			DiceCombo.ABILITY_TYPE.DAMAGE:
				power = info.damage

			DiceCombo.ABILITY_TYPE.COMBINATION:
				power = info.damage + info.health

		if !strongest.has(type):
			strongest[type] = entry
		else:
			var current_best = strongest[type]
			var current_info = DiceCombo.get_dice_combo_info(current_best.current_dc)

			var current_power := 0.0

			match type:
				DiceCombo.ABILITY_TYPE.HEAL:
					current_power = current_info.health

				DiceCombo.ABILITY_TYPE.DAMAGE:
					current_power = current_info.damage

				DiceCombo.ABILITY_TYPE.COMBINATION:
					current_power = current_info.damage + current_info.health

			if power > current_power:
				strongest[type] = entry

	for child in get_children():
		var entry := child as Dice_Combo_Entry
		if entry == null:
			continue
		if !entry.can_use_ability:
			continue

		var info = DiceCombo.get_dice_combo_info(entry.current_dc)

		if strongest[info.ability_type] != entry:
			entry.visible = false
	
