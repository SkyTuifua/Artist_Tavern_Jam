extends Sprite3D
class_name Side

enum SIDE_COLORS {BLUE, GREEN, RED}
@export var color : SIDE_COLORS = SIDE_COLORS.BLUE	
@export var value: int

func _ready() -> void:
	texture = get_side_texture(color)
	

##A Helper function to help you get the texture of a side.
func get_side_texture(color : SIDE_COLORS)->Texture2D:
	match color:
		SIDE_COLORS.RED:
			return load("res://Dice Scenes/Dice_Symbols/dice_damage_plus_v3.png")
		SIDE_COLORS.BLUE:
			return load("res://Dice Scenes/Dice_Symbols/dice_base_damage.png")
		SIDE_COLORS.GREEN:
			return load("res://Dice Scenes/Dice_Symbols/dice_base_health.png")
	return load("res://Dice Scenes/Dice_Symbols/Blue.tres")
