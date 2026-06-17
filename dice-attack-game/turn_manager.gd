extends Node
class_name Turn_Manager

@onready var reroll_button = $"../RerollButton"
@onready var slots = $"../CanvasLayer/DiceUI/DiceSlots"
@onready var dice_textures = {
	1: preload("res://Dice Scenes/Dice_Symbols/dice_base_damage.png"),
	2: preload("res://Dice Scenes/Dice_Symbols/dice_base_health.png"),
	3: preload("res://Dice Scenes/Dice_Symbols/dice_damage_plus_v2.png"),
}
@export var dice_array : Array[Dice]
@export var dice_height : float = 4.0 ## The height at which the dice start when they are rolled.
@export var random_impulse_strength_min : float = -1.5
@export var random_impulse_strength_max : float = 1.5
var can_check_if_roll_is_done : bool = true
var reroll_selection_mode: bool = false
var selected_die_idx: int = -1
func _ready() -> void:
	reroll_button.visible = false
	for i in dice_array:
		if !i.ready:
			await i.ready
		i.freeze = true
		i.visible = false
		i.stopped.connect(check_if_roll_is_done)
	for i in range(slots.get_child_count()):
		var panel = slots.get_child(i)
		panel.gui_input.connect(_on_slot_input.bind(i))
		panel.mouse_entered.connect(_on_panel_mouse_entered.bind(panel))
		panel.mouse_exited.connect(_on_panel_mouse_exited.bind(panel))
		
func get_face_texture(value: int) -> Texture2D:
	return dice_textures[value]
	
func roll_dice(target_dice: Array = dice_array)->void:
	can_check_if_roll_is_done = true
	reroll_button.visible = false
	for dice in target_dice:
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
			on_roll_finished()
			
		
func on_roll_finished():
	calculate_roll()
	reroll_button.visible = true
	$"../CanvasLayer/DiceUI".visible = true
	slots.visible = true
	for i in range(dice_array.size()):
		var dice = dice_array[i]
		var panel = slots.get_child(i)
		var texture_rect = panel.get_child(0)

		texture_rect.texture = get_face_texture(dice.current_side.value)
	
func calculate_roll()->void:
	for i in dice_array:
		i.get_top_facing_side()
		i.freeze = true
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

func _on_reroll_button_pressed():
	reroll_selection_mode = true
	selected_die_idx = -1
	enable_slot_highlight(true)

func enable_slot_highlight(enable: bool):
	for slot in slots.get_children():
		if enable:
			slot.modulate = Color(1, 1, 0.5)
		else:
			slot.modulate = Color(1, 1, 1)	

func _on_slot_input(event: InputEvent, index: int):
	if not reroll_selection_mode:
		return
	
	if event is InputEventMouseButton and event.pressed:
		select_die_for_reroll(index)
		
func select_die_for_reroll(index: int):
	selected_die_idx = index

	for i in range(slots.get_child_count()):
		var slot = slots.get_child(i)
		slot.modulate = Color(1, 1, 0.5)
		slot.scale = Vector2(1.1, 1.1)
	
	var selected_slot = slots.get_child(index)
	selected_slot.modulate = Color(1, 0.6, 0.6)
	
	var dice = dice_array[index]
	roll_dice([dice])
	
func finish_reroll_selection():
	reroll_selection_mode = false
	selected_die_idx = -1
	enable_slot_highlight(true)
	

func _on_panel_mouse_entered(panel: Panel) -> void:
	print("hovering", panel.name)
	if reroll_selection_mode:
		panel.scale = Vector2(1.5, 1.5)


func _on_panel_mouse_exited(panel: Panel) -> void:
	panel.scale = Vector2.ONE
