extends Control
class_name Combo_Info_Entry

@onready var combination_pictures: HBoxContainer = %Combination_Pictures
var current_dc : DiceCombo.DICE_COMBOS
@onready var ability_name: Label = %"Ability Name"
@onready var description: HBoxContainer = %Description

var definitions_size : float = 15.0
var texture_size : float = 50

signal entry_chosen(dice_combo : DiceCombo.DICE_COMBOS)

func apply_info(dice_combo : DiceCombo.DICE_COMBOS = DiceCombo.DICE_COMBOS.VAMPIRE_BITE)->void:
	current_dc = dice_combo
	var dci : DiceCombo.dice_combo_info = DiceCombo.get_dice_combo_info(dice_combo)
	ability_name.text = dci.name
	if dci.health:
		create_new_combo_definition("Heal", dci.health)
	if dci.damage:
		create_new_combo_definition("Damage", dci.damage)
	for i in dci.combination:
		create_combo_textures(i)

func get_combo_info(dice_combo : DiceCombo.DICE_COMBOS = DiceCombo.DICE_COMBOS.VAMPIRE_BITE)->DiceCombo.dice_combo_info:
	var dci : DiceCombo.dice_combo_info = DiceCombo.get_dice_combo_info(dice_combo)
	return dci
	
func create_combo_textures(side_texture : Side.SIDE_COLORS)->void:
	var new_texture := TextureRect.new()
	new_texture.texture = Side.get_side_texture(side_texture)
	new_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	new_texture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	new_texture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	new_texture.custom_minimum_size = Vector2(texture_size,texture_size)
	combination_pictures.add_child(new_texture)
	
func create_new_combo_definition(def_name : String, def_value)->void:
	if !def_name or !def_value:
		return
	var new_label : Label = Label.new()
	new_label.text = def_name + ": " + str(def_value)
	new_label.label_settings = LabelSettings.new()
	new_label.label_settings.font_size = definitions_size
	description.add_child(new_label)
	
