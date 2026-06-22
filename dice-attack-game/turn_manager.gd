extends Node
class_name Turn_Manager

@onready var reroll_button: Button = %RerollBtn
@onready var help_panel: PanelContainer = %help_panel
@onready var init_roll_btn: Button = %InitialRollBtn
@export var dice_array : Array[Dice]
@export var dice_height : float = 4.0 ## The height at which the dice start when they are rolled.
@export var random_impulse_strength_min : float = -1.5
@export var random_impulse_strength_max : float = 1.5
var dice_to_reroll : Array[Dice]
var dice_combo : Array[Side.SIDE_COLORS] ##What the player rolled
var rolling : bool = false #if dice pool is currently being rolled
var reroll_selection_mode: bool = false
var selected_die_idx: int = -1
var game_started: bool = false
@onready var combo_entries_container: VBoxContainer = %"Combo Entries Container"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var vamp_anim: AnimationPlayer = %"VampAnimation"
@onready var turn_ui: CanvasLayer = %Turn_UI
@onready var turn_data_ui: CanvasLayer = %TurnDataUI
@onready var choose_dice_text: Label = %ChooseDiceText
@onready var current_abilities: VBoxContainer = %"Current Abilities"
@onready var settings_container: VBoxContainer = %SettingsContainer
@onready var settings_btn: TextureButton = %settings_btn



@onready var health_bars: CanvasLayer = %Health_Bars
@onready var enemy_health: ProgressBar = %"Enemy Health"
@onready var enemy_busy := false
@onready var player_health: ProgressBar = %Player_Health
@onready var turn_label: Label = %TurnLabel
@onready var turn_result: Label = %TurnResult
@onready var reroll_count_label: Label = %reroll_sub_text
var max_reroll_count : int = 2
@onready var current_reroll_count : int = max_reroll_count
@onready var win_lose_label: Label = %Win_Lose_Label

@onready var coin_mult: Node3D = %CoinMultiplier
@onready var blood_effect: ColorRect = %"Blood Effect"

#Sounds
@onready var player_damaged: AudioStreamPlayer = %Player_Damaged
@onready var player_healed: AudioStreamPlayer = %Player_Healed
@onready var villain_damaged: AudioStreamPlayer = %Villain_Damaged
@onready var villain_healed: AudioStreamPlayer = %Villain_Healed
@onready var roll_dice_sound: AudioStreamPlayer = %Roll_Dice
@onready var i_want_blood_sound: AudioStreamPlayer = %I_Want_Blood


enum TurnState {
	PLAYER,
	ENEMY
}
var current_turn := TurnState.PLAYER

signal turn_finished()

func _ready() -> void:
	turn_ui.visible = false
	reroll_button.visible = false
	help_panel.visible = false
	init_roll_btn.visible = false
	animation_player.play("table_to_pov")
	await animation_player.animation_finished
	await get_tree().create_timer(1.0).timeout
	roll_dice_sound.play()
	return_to_table()
	await get_tree().create_timer(1.0).timeout
	turn_data_ui.visible = true

	for i in dice_array:
		if !i.ready:
			await i.ready
		i.input_event.connect(handle_dice_clicked.bind(i))
		i.mouse_entered.connect(handle_dice_hovered.bind(i))
		i.mouse_exited.connect(handle_dice_exited.bind(i))
		i.freeze = true
		i.visible = false
		i.stopped.connect(check_if_roll_is_done)
		
	game_started = false
	
func roll_dice(target_dice: Array = dice_array)->void:
	game_started = true
	rolling = true
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
func handle_dice_clicked(camera : Node, event : InputEvent, event_position : Vector3, normal : Vector3, shape_idx: int, dice : Dice)->void:
	if current_turn != TurnState.PLAYER or rolling or init_roll_btn.visible or current_reroll_count <= 0:
		return
	if Input.is_action_just_pressed("mouse_click"):
		if dice_to_reroll.has(dice):
			dice_to_reroll.erase(dice)
			dice.selected_hint.visible = false
			if dice_to_reroll.is_empty():
				reroll_button.visible = false
				help_panel.visible = true
			return
		dice_to_reroll.push_back(dice)
		dice.selected_hint.visible = true
		reroll_button.visible = true
		help_panel.visible = false
		
func handle_dice_hovered(dice : Dice)->void:
	if current_turn != TurnState.PLAYER or rolling or init_roll_btn.visible or current_reroll_count <= 0:
		return
	dice.hover_hint.visible = true
	
func handle_dice_exited(dice : Dice)->void:
	if current_turn != TurnState.PLAYER:
		return
	dice.hover_hint.visible = false
func should_trigger_coin() -> bool:
	return randf() <= .2

func get_coin_multiplier() -> float:

	if !should_trigger_coin():
		return 1.0
		
	turn_result.text = "Blood Coin Bonus! 1.5x Ability Chance!"
		
	i_want_blood_sound.play()
	coin_mult.start_coin_flow()

	await coin_mult.coin_finished

	if coin_mult.current_coin_result == coin_mult.CoinResult.HEADS:
		turn_result.text = "1.5x Ability Awarded!"
		return 1.5

	turn_result.text = "Blood Coin! No Bonus!"
	return 1.0
	
func check_if_roll_is_done()->void:
	if not game_started:
		return
	var roll_done : bool = true
	for i in dice_array:
		if i.dice_moving:
			roll_done = false

	if roll_done and rolling:
		on_roll_finished()
		
func on_roll_finished():
	reroll_button.visible = false
	help_panel.visible = true
	if game_started == false:
		return
	rolling = false
	help_panel.visible = true
	current_abilities.visible = true
	calculate_roll()
	if(current_turn == TurnState.PLAYER):
		help_panel.visible = true
	if current_turn == TurnState.ENEMY:
		await get_tree().create_timer(0.2).timeout
		await resolve_enemy_roll()

			
func resolve_enemy_roll() -> void:
	var chosen_combo = choose_enemy_combo()
	print("Resolve Enemy Roll")
	print(chosen_combo)
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
	print("=== CHOOSE ENEMY COMBO ===")
	print("dice_combo:", dice_combo)
	var combos = DiceCombo.get_available_combos(dice_combo)

	if combos.is_empty():
		return DiceCombo.DICE_COMBOS.DAMAGE

	# Only one option
	if combos.size() == 1:
		return combos[0]

	# Can kill player?
	for combo in combos:
		print("Choose enemy Combo")
		print(combo)
		if combo == null:
			push_error("NULL COMBO FOUND!")
			continue
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
		play_screen_fx(Color.RED)
		player_damaged.play()
	if dci.health:
		enemy_health.value += dci.health * mult
		villain_healed.play()
		vamp_anim.play("health")

	if enemy_health.value <= 0 or player_health.value <= 0:
		end_game()
	
func calculate_roll()->void:
	dice_combo.clear()
	for dice in dice_array:
		dice.freeze = true
		dice.get_top_facing_side()
		dice_combo.push_back(dice.current_side.color)
	dice_combo.sort()
	var texture_size : float = 65
	
	combo_entries_container.clear_entries()
	combo_entries_container.create_entries(dice_combo)
	
func sort_dice(a:Dice, b:Dice)->bool:
	if a.current_side.color < b.current_side.color :
		return true
	return false

func _on_reroll_button_pressed():
	current_reroll_count -= 1
	reroll_count_label.text = "Rerolls left: " + str(current_reroll_count)
	roll_dice(dice_to_reroll)
	reroll_button.visible = false
	for i in dice_to_reroll:
		i.selected_hint.visible = false
	dice_to_reroll.clear()
##Attack Has been chosen, Play animation to attack, and hide UI until Animation is done?
func _on_combo_entries_container_entry_chosen(combo: DiceCombo.DICE_COMBOS) -> void:
	animation_player.play("table_to_pov")
	for i in dice_to_reroll:
		i.hover_hint.visible = false
		i.selected_hint.visible = false
	dice_to_reroll.clear()
	turn_ui.visible = false
	
	await animation_player.animation_finished

	
	#health_bars.visible = true
	
	
	await do_attack(combo)
	await get_tree().create_timer(1.0).timeout
	current_turn = TurnState.ENEMY
	change_turn_data()
	await enemy_turn()

	
#does the attack
func do_attack(combo : DiceCombo.DICE_COMBOS)->void:
	print("Do ATTACK")
	print(combo)
	var dci : DiceCombo.dice_combo_info = DiceCombo.get_dice_combo_info(combo)
	var multiplier = await get_coin_multiplier()
	
	if dci.damage:
		enemy_health.value -= dci.damage * multiplier
		villain_damaged.play()
		vamp_anim.play("damage")
	if dci.health:
		player_health.value += dci.health * multiplier
		play_screen_fx(Color.SEA_GREEN)
		player_healed.play()
		
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

	await get_tree().create_timer(0.5).timeout
	roll_dice()
	
func return_to_table()->void:
	animation_player.play("table_to_pov", -1, -1.0, true)
	

	await animation_player.animation_finished
	init_roll_btn.visible = true
	change_turn_data()

func change_turn_data():
	if current_turn == TurnState.PLAYER:
		turn_ui.visible = true
		turn_label.text = "Your Turn"
		reroll_button.visible = false
		current_reroll_count = max_reroll_count
		reroll_count_label.text = "Rerolls left: " + str(current_reroll_count)
	else:
		turn_label.text = "Enemy Turn"
	current_abilities.visible = false

###############################################################################################
func play_screen_fx(screen_color : Color = Color.RED, damage_fx_time : float = .7)->void:
	blood_effect.color = screen_color
	
	blood_effect.modulate = Color.WHITE
	get_tree().create_tween().tween_property(blood_effect,"modulate",Color.TRANSPARENT, damage_fx_time)
	#tween.finished.connect(func(): blood_effect.visible = false)
#end game logic.
func end_game()->void:
	print(player_health)
	win_lose_label.visible = true
	if player_health.value <= 0:
		win_lose_label.text = "You lose"
	else:
		win_lose_label.text = "You Win"
	get_tree().create_timer(3).timeout.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))


func _on_settings_btn_pressed() -> void:
	settings_container.visible = true
