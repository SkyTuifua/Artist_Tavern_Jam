extends Node
class_name Turn_Manager

@onready var reroll_button: Button = %RerollButton
@onready var init_roll_btn: Button = %InitialRollBtn
@onready var slots: HBoxContainer = %DiceSlots
@export var dice_array : Array[Dice]
@export var dice_height : float = 4.0 ## The height at which the dice start when they are rolled.
@export var random_impulse_strength_min : float = -1.5
@export var random_impulse_strength_max : float = 1.5
var dice_combo : Array[Side.SIDE_COLORS] ##What the player rolled
var can_check_if_roll_is_done : bool = true
var reroll_selection_mode: bool = false
var selected_die_idx: int = -1
var game_started: bool = false
@onready var combo_entries_container: VBoxContainer = %"Combo Entries Container"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var turn_ui: CanvasLayer = %Turn_UI
@onready var turn_data_ui: CanvasLayer = %TurnDataUI
@onready var dice_ui: Control = %DiceUI
@onready var choose_dice_text: RichTextLabel = $"../TurnDataUI/DiceUI/ChooseDiceText"
@onready var scroll_container: ScrollContainer = $"../Turn_UI/ScrollContainer"


@onready var health_bars: CanvasLayer = %Health_Bars
@onready var enemy_health: ProgressBar = %"Enemy Health"
@onready var enemy_busy := false
@onready var player_health: ProgressBar = %Player_Health
@onready var turn_label: Label = %TurnLabel
@onready var turn_result: Label = %TurnResult
@onready var coin_mult: Node3D = %CoinMultiplier

enum TurnState {
	PLAYER,
	ENEMY
}
var current_turn := TurnState.PLAYER


signal turn_finished()


func _ready() -> void:
	reroll_button.visible = false
	turn_data_ui.visible = true

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
	
func roll_dice(target_dice: Array = dice_array)->void:
	game_started = true
	can_check_if_roll_is_done = true
	init_roll_btn.visible = false
	for dice in target_dice:
		var new_transform : Transform3D
		dice.freeze = false
		dice.visible = true
		new_transform = dice.global_transform
		new_transform.origin.y = dice_height
		new_transform = new_transform.rotated(Vector3(randf(),randf(),randf()), randf())
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

func should_trigger_coin() -> bool:
	return randf() <= .90

func get_coin_multiplier() -> float:

	if !should_trigger_coin():
		return 1.0

	coin_mult.start_coin_flow()

	await coin_mult.coin_finished

	if coin_mult.current_coin_result == coin_mult.CoinResult.HEADS:
		turn_result.text = "Blood Coin! 2x Ability!"
		return 2.0

	turn_result.text = "Blood Coin! No Bonus!"
	return 1.0
	
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
	if game_started == false:
		return
	reroll_button.visible = true
	scroll_container.visible = true
	calculate_roll()
	dice_ui.visible = true
	update_slot_textures()
	if(current_turn == TurnState.PLAYER):
		reroll_button.visible = true
	else:
		choose_dice_text.text = "Enemy Rolled"
	if current_turn == TurnState.ENEMY:
		await get_tree().create_timer(0.2).timeout
		await resolve_enemy_roll()

func update_slot_textures():
	var count = min(dice_array.size(), slots.get_child_count())

	for i in range(count):
		var dice = dice_array[i]
		var texture_rect = slots.get_child(i) as TextureRect

		if texture_rect == null:
			continue

		if dice.current_side == null:
			texture_rect.texture = null
		else:
			texture_rect.texture = Side.get_side_texture(dice.current_side.color)
			
func resolve_enemy_roll() -> void:
	var chosen_combo = choose_enemy_combo()
	var dci = DiceCombo.get_dice_combo_info(chosen_combo)

	turn_result.text = "Enemy used: " + dci.name

	await get_tree().create_timer(1.0).timeout
	await do_enemy_attack(chosen_combo)
	await get_tree().create_timer(1.0).timeout

	turn_result.text = ""
	enemy_busy = false
	current_turn = TurnState.PLAYER	
	change_turn_data()
	await get_tree().create_timer(0.5).timeout
	await return_to_table()


func choose_enemy_combo():

	var combos = DiceCombo.get_available_combos(dice_combo)

	if combos.is_empty():
		return null

	# Only one option
	if combos.size() == 1:
		return combos[0]

	# Can kill player?
	for combo in combos:
		var dci = DiceCombo.get_dice_combo_info(combo)

		if dci.damage >= player_health.value:
			return combo

	# Vampire Bite always
	if combos.has(DiceCombo.DICE_COMBOS.VAMPIRE_BITE):
		return DiceCombo.DICE_COMBOS.VAMPIRE_BITE

	# Heal if low
	var hp_percent = enemy_health.value / enemy_health.max_value

	if hp_percent <= 0.25:
		if combos.has(DiceCombo.DICE_COMBOS.HEAL):
			return DiceCombo.DICE_COMBOS.HEAL

	# Damage if healthy
	if combos.has(DiceCombo.DICE_COMBOS.DAMAGE_PLUS):
		return DiceCombo.DICE_COMBOS.DAMAGE_PLUS

	if combos.has(DiceCombo.DICE_COMBOS.DAMAGE):
		return DiceCombo.DICE_COMBOS.DAMAGE

	return combos[0]
	

func do_enemy_attack(combo) -> void:
	var dci = DiceCombo.get_dice_combo_info(combo)
	var mult = await get_coin_multiplier()
	if dci.damage:
		player_health.value -= dci.damage * mult

	if dci.health:
		enemy_health.value += dci.health * mult

	if enemy_health.value <= 0 or player_health.value <= 0:
		end_game()
	
func calculate_roll()->void:
	for i in dice_array:
		i.get_top_facing_side()
		i.freeze = true
	dice_combo.clear()
	for dice in dice_array:
		dice_combo.push_back(dice.current_side.color)
	dice_combo.sort()
	
	#remove entries before creating a new list of combo entries.
	combo_entries_container.clear_entries()
	combo_entries_container.create_entries(dice_combo)
	
func sort_dice(a:Dice, b:Dice)->bool:
	if a.current_side.color < b.current_side.color :
		return true
	return false
	
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
	enable_slot_highlight(true)

##Attack Has been chosen, Play animation to attack, and hide UI until Animation is done?
func _on_combo_entries_container_entry_chosen(combo: DiceCombo.DICE_COMBOS) -> void:
	animation_player.play("table_to_pov")
	await animation_player.animation_finished

	turn_ui.visible = false
	health_bars.visible = true

	await do_attack(combo)
	await get_tree().create_timer(1.0).timeout
	current_turn = TurnState.ENEMY
	change_turn_data()
	await enemy_turn()

	
#does the attack
func do_attack(combo : DiceCombo.DICE_COMBOS)->void:
	var dci : DiceCombo.dice_combo_info = DiceCombo.get_dice_combo_info(combo)
	var multiplier = await get_coin_multiplier()
	
	if dci.damage:
		enemy_health.value -= dci.damage * multiplier
	if dci.health:
		player_health.value += dci.health * multiplier
	if enemy_health.value <= 0 or player_health.value <= 0:
		end_game()
		return
			
#choose a random attack for the ai to use based on the probabilities of dice rolls
func enemy_turn() -> void:
	print("TURN")
	if enemy_busy:
		return
	enemy_busy = true
	current_turn = TurnState.ENEMY
	change_turn_data()
	print("should roll here")

	await get_tree().create_timer(0.5).timeout
	roll_dice()
	
func return_to_table()->void:
	animation_player.play("table_to_pov", -1, -1.0, true)
	change_turn_data()
	animation_player.animation_finished.connect(attack_finished, CONNECT_ONE_SHOT)
	dice_ui.visible = false
	
	await animation_player.animation_finished
	attack_finished("")

func change_turn_data():
	if current_turn == TurnState.PLAYER:
		turn_label.text = "Your Turn"
		init_roll_btn.visible = true
		reroll_button.visible = false
	else:
		turn_label.text = "Enemy Turn"
	dice_ui.visible = false
	scroll_container.visible = false
func attack_finished(anim_name:StringName)->void:
	turn_ui.visible = true
	health_bars.visible = false
###############################################################################################

#end game logic.
func end_game()->void:
	pass
