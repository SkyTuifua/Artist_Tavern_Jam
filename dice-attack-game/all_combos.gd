extends VBoxContainer

func _ready() -> void:
	for i in range(DiceCombo.DICE_COMBOS.size()):
		var instance : Combo_Info_Entry = preload("res://UI/Combo_Info_Entry.tscn").instantiate()
		instance.ready.connect(setup_entry.bind(instance, i))
		add_child(instance)
		
func setup_entry(new_entry : Combo_Info_Entry, combo : DiceCombo.DICE_COMBOS)->void:
	print(combo)
	new_entry.apply_info(combo)
