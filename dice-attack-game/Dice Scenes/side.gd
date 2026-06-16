extends Sprite3D
class_name Side

enum SIDE_COLORS {BLUE, GREEN, RED}
@export var color : SIDE_COLORS = SIDE_COLORS.BLUE	

func _ready() -> void:
	texture = get_side_texture(color)
	

##A Helper function to help you get the texture of a side.
func get_side_texture(color : SIDE_COLORS)->Texture2D:
	match color:
		SIDE_COLORS.RED:
			return load("res://Dice Scenes/Dice_Symbols/Red.tres")
		SIDE_COLORS.BLUE:
			return load("res://Dice Scenes/Dice_Symbols/Blue.tres")
		SIDE_COLORS.GREEN:
			return load("res://Dice Scenes/Dice_Symbols/Green.tres")
	return load("res://Dice Scenes/Dice_Symbols/Blue.tres")
