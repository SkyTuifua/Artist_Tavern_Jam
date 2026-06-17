extends MarginContainer
class_name Dice_Combo_Entry
@onready var combo_name: Label = $VSplitContainer/HSplitContainer/Combo_Name
@onready var definitions: VBoxContainer = $VSplitContainer/HSplitContainer/Definitions
@onready var combonation_pictures: HBoxContainer = $VSplitContainer/Combonation_Pictures
@onready var use_ability_button: Button = $VSplitContainer/Use_Ability_Button
@onready var use_ability_text: Label = $VSplitContainer/Use_Ability_Button/Use_Ability_text
var current_dc : DiceCombo.DICE_COMBOS
var can_use_ability : bool = true

var definitions_size : float = 15.0

signal entry_chosen(dice_combo : DiceCombo.DICE_COMBOS)

func apply_info(dice_combo : DiceCombo.DICE_COMBOS = DiceCombo.DICE_COMBOS.VAMPIRE_BITE)->void:
	current_dc = dice_combo
	var dci : DiceCombo.dice_combo_info = DiceCombo.get_dice_combo_info(dice_combo)
	combo_name.text = dci.name
	if dci.health:
		create_new_combo_definition("Heal", dci.health)
	if dci.damage:
		create_new_combo_definition("Damage", dci.damage)
	for i in dci.combination:
		create_combo_textures(i)
	
func create_combo_textures(side_texture : Side.SIDE_COLORS)->void:
	var new_texture := TextureRect.new()
	new_texture.texture = Side.get_side_texture(side_texture)
	combonation_pictures.add_child(new_texture)
	
func create_new_combo_definition(def_name : String, def_value)->void:
	if !def_name or !def_value:
		return
	var new_label : Label = Label.new()
	new_label.text = def_name + ": " + str(def_value)
	new_label.label_settings = LabelSettings.new()
	new_label.label_settings.font_size = definitions_size
	definitions.add_child(new_label)
	
func set_can_use_ability(b : bool)->void:
	can_use_ability = b
	use_ability_button.disabled = !b
	if b:
		use_ability_text.text = "Use Ability"
	else:
		use_ability_text.text = "Can't Use"
	print(use_ability_button.disabled)
	


func _on_use_ability_button_pressed() -> void:
	entry_chosen.emit(current_dc)
