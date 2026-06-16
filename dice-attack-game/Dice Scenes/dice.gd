extends RigidBody3D
class_name Dice
@export var sides : Array[Node3D]
var current_side : Side
var dice_moving : bool = false
signal stopped()
#func _physics_process(delta: float) -> void:
	#for i in sides:
		#print(i.name, " ", i.global_transform.basis.z.normalized().dot(Vector3.UP))


func _on_sleeping_state_changed() -> void:
	var stop_signel_send_time : float = 1.0
	if linear_velocity == Vector3.ZERO  and angular_velocity == Vector3.ZERO:
		dice_moving = false
		stopped.emit()
	else:
		dice_moving = true
##Checks which side is closest to the given Vector3. Vector3.UP is default, which will give the side that faces up. and returns that side.
func get_top_facing_side(comp_vector : Vector3 = Vector3.UP)->void:
	var top_facing_side : Side = sides[0]
	if sleeping:
		for i in sides:
			if i.global_transform.basis.z.normalized().dot(comp_vector) >= top_facing_side.global_transform.basis.z.normalized().dot(comp_vector):
				top_facing_side = i
	current_side = top_facing_side
	
