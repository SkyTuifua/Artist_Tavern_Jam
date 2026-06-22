extends Node3D

var enemies = [
	{
		"name": "Big Vamp",
		"scene": preload("res://characters/bigVamp.glb"),
		"health": 200
	},
	{
		"name": "Vampiona",
		"scene": preload("res://characters/girl_vamp.glb"),
		"health": 150
	},
	{
		"name": "Dr. Vamp",
		"scene": preload("res://characters/vamp_enemy.glb"),
		"health": 100
	}
]
@onready var name_label = %EnemyName
@onready var enemy
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	enemy = enemies.pick_random()

	name_label.text = enemy["name"]

	var character = enemy["scene"].instantiate()
	add_child(character)

func get_enemy_data():
	return enemy
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
