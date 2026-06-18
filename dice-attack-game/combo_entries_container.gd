extends VBoxContainer
class_name Entries_Container

signal entry_chosen(combo : DiceCombo.DICE_COMBOS)

func create_entries(player_roll : Array[Side.SIDE_COLORS])->void:
	
	#create combo entries, and check to see if the current roll has the required combination.
	for i in range(DiceCombo.DICE_COMBOS.size()):
		var new_entry : Dice_Combo_Entry = preload("res://UI/dice_combo_entry.tscn").instantiate()
		new_entry.ready.connect(setup_combo_entry.bind(new_entry, i, player_roll))
		add_child(new_entry)
		
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
	
