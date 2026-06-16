extends RigidBody3D
class_name Dice
@export var sides : Array[Node3D]
signal stopped()
#func _physics_process(delta: float) -> void:
	#for i in sides:
		#print(i.name, " ", i.global_transform.basis.z.normalized().dot(Vector3.UP))


func _on_sleeping_state_changed() -> void:
	if linear_velocity <= Vector3.ZERO  and angular_velocity <= Vector3.ZERO:
		stopped.emit()

func get_top_facing_side()->Side:
	if sleeping:
		for i in sides:
			if i.global_transform.basis.z.normalized().dot(Vector3.UP) >= .9:
				return i
		return null
	else:
		printerr("Dice is not stopped yet.", self)
		return null
