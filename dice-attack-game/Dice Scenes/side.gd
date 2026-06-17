extends Sprite3D
class_name Side

enum SIDE_COLORS {BASE_DAMAGE, BASE_HEALTH, DAMAGE_PLUS}
@export var color : SIDE_COLORS = SIDE_COLORS.BASE_DAMAGE	
@export var value: int

func _ready() -> void:
	texture = get_side_texture(color)
	

##A Helper function to help you get the texture of a side.
static func get_side_texture(color : SIDE_COLORS)->Texture2D:
	match color:
		SIDE_COLORS.DAMAGE_PLUS:
			return load("res://Dice Scenes/Dice_Symbols/dice_damage_plus_v3.png")
		SIDE_COLORS.BASE_DAMAGE:
			return load("res://Dice Scenes/Dice_Symbols/dice_base_damage.png")
		SIDE_COLORS.BASE_HEALTH:
			return load("res://Dice Scenes/Dice_Symbols/dice_base_health.png")
	return load("res://Dice Scenes/Dice_Symbols/Blue.tres")
