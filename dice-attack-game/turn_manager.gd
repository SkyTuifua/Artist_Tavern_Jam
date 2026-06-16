extends Node
class_name Turn_Manager

@export var dice_array : Array[Dice]
@export var dice_height : float = 4.0 ## The height at which the dice start when they are rolled.
@export var random_impulse_strength_min : float = -1.5
@export var random_impulse_strength_max : float = 1.5
var can_check_if_roll_is_done : bool = true
func _ready() -> void:
	for i in dice_array:
		if !i.ready:
			await i.ready
		i.freeze = true
		i.visible = false
		i.stopped.connect(check_if_roll_is_done)
func roll_dice()->void:
	can_check_if_roll_is_done = true
	
	for dice in dice_array:
		var new_transform : Transform3D
		dice.freeze = false
		dice.visible = true
		new_transform = dice.global_transform
		new_transform.origin.y = dice_height
		PhysicsServer3D.body_set_state(dice,PhysicsServer3D.BODY_STATE_TRANSFORM,new_transform)
		dice.apply_central_impulse(Vector3(
			randf_range(random_impulse_strength_min, random_impulse_strength_max), 
			randf_range(random_impulse_strength_min, random_impulse_strength_max), 
			randf_range(random_impulse_strength_min, random_impulse_strength_max)
			))
		dice.apply_torque_impulse(Vector3(
			randf_range(random_impulse_strength_min, random_impulse_strength_max), 
			randf_range(random_impulse_strength_min, random_impulse_strength_max), 
			randf_range(random_impulse_strength_min, random_impulse_strength_max)
			))
	
func check_if_roll_is_done()->void:
		var roll_done : bool = true
		for i in dice_array:
			if i.dice_moving:
				roll_done = false
		
		if roll_done and can_check_if_roll_is_done:
			print(roll_done) 
			can_check_if_roll_is_done = false
			calculate_roll()
		
func calculate_roll()->void:
	for i in dice_array:
		i.get_top_facing_side()
		i.freeze
	move_dice_into_position()
	
func sort_dice(a:Dice, b:Dice)->bool:
	if a.current_side.color < b.current_side.color :
		return true
	return false
	
func move_dice_into_position()->void:
	print("-------NEW TABLE------------")
	dice_array.sort_custom(sort_dice)	
	for i in dice_array:
		print(i.name , " ", i.current_side.color)
