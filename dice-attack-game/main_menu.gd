extends Control

@onready var settings = %SettingsContainer
@onready var rulesPanel = %RulesPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings.visible = false
	rulesPanel.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_settings_pressed() -> void:
	settings.visible = !settings.visible


func _on_rules_pressed() -> void:
	rulesPanel.visible = !rulesPanel.visible


func _on_close_rules_btn_pressed() -> void:
	rulesPanel.visible = false
