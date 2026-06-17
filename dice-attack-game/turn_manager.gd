extends Node
class_name Turn_Manager

@onready var reroll_button = $"../RerollButton"
@onready var slots = $"../CanvasLayer/DiceUI/DiceSlots"
@onready var dice_textures = {
	1: preload("res://Dice Scenes/Dice_Symbols/dice_base_damage.png"),
	2: preload("res://Dice Scenes/Dice_Symbols/dice_base_health.png"),
	3: preload("res://Dice Scenes/Dice_Symbols/dice_damage_plus_v3.png"),
}
@export var dice_array : Array[Dice]
@export var dice_height : float = 4.0 ## The height at which the dice start when they are rolled.
@export var random_impulse_strength_min : float = -1.5
@export var random_impulse_strength_max : float = 1.5
var can_check_if_roll_is_done : bool = true
var reroll_selection_mode: bool = false
var selected_die_idx: int = -1
var game_started: bool = false
enum RollResult {
	NONE,
	DAMAGE_25,
	DAMAGE_50,
	HEAL_25,
	VAMPIRE_BITE
}

func _ready() -> void:
	reroll_button.visible = false
	$"../CanvasLayer/DiceUI/ChooseDiceText".visible = false
	for i in dice_array:
		if !i.ready:
			await i.ready

		i.freeze = true
		i.visible = false

		i.stopped.connect(check_if_roll_is_done)
	for i in range(slots.get_child_count()):
		var slot = slots.get_child(i)
		slot.gui_input.connect(_on_slot_input.bind(i))
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
	game_started = false
	
	for p in slots.get_children():
		print(p.name, " global rect: ", p.get_global_rect())
		
func get_face_texture(value: int) -> Texture2D:
	return dice_textures[value]
	
func roll_dice(target_dice: Array = dice_array)->void:
	game_started = true
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
	if not game_started:
		return

	var roll_done : bool = true

	for i in dice_array:
		if i.dice_moving:
			roll_done = false

	if roll_done and can_check_if_roll_is_done:
		can_check_if_roll_is_done = false
		on_roll_finished()
			
		
func on_roll_finished():
	calculate_roll()
	reroll_button.visible = true
	$"../CanvasLayer/DiceUI".visible = true

	slots.visible = true

	var count = min(dice_array.size(), slots.get_child_count())

	for i in range(count):
		var dice = dice_array[i]
		var texture_rect = slots.get_child(i) as TextureRect

		if texture_rect == null:
			continue

		if dice.current_side == null:
			texture_rect.texture = null
		else:
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
	var damage_count := 0
	var health_count := 0
	var damage_plus_count := 0

	for dice in dice_array:
		match dice.current_side.value:
			1:
				damage_count += 1
			2:
				health_count += 1
			3:
				damage_plus_count += 1
				
	var result = DiceCombo.resolve(
		damage_count,
		health_count,
		damage_plus_count
	)

	print(result.name)

func enable_slot_highlight(enable: bool):
	for slot in slots.get_children():
		if enable:
			slot.modulate = Color(1, 1, 1)
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
		slot.modulate = Color(1, 1, 1)
		slot.scale = Vector2.ONE

	var selected_slot = slots.get_child(index)
	selected_slot.modulate = Color(1, 0.6, 0.6)
	selected_slot.scale = Vector2(1.15, 1.15)

	# reroll ONLY that die
	var dice = dice_array[index]
	roll_dice([dice])
	
func finish_reroll_selection():
	reroll_selection_mode = false
	selected_die_idx = -1
	enable_slot_highlight(true)

func _on_reroll_button_pressed():
	reroll_selection_mode = true
	selected_die_idx = -1
	$"../CanvasLayer/DiceUI/ChooseDiceText".visible = true

	enable_slot_highlight(true)
