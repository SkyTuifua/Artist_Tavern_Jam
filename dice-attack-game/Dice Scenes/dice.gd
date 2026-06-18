extends RigidBody3D
class_name Dice
@export var sides : Array[Side]
var current_side : Side = null
var has_rolled : bool = false
var dice_moving : bool = false
signal stopped()
var still_time: float = 0.0
const STILL_THRESHOLD := 0.05
const REQUIRED_STILL_TIME := 0.5
var finished: bool = false


func _physics_process(delta: float) -> void:
	var moving := linear_velocity.length() > STILL_THRESHOLD \
		or angular_velocity.length() > STILL_THRESHOLD

	if moving:
		# reset stability tracking while moving
		still_time = 0.0
		dice_moving = true
		finished = false
		return

	# accumulate stable time
	still_time += delta

	# only trigger once when truly settled
	if still_time >= REQUIRED_STILL_TIME and not finished:
		finished = true
		dice_moving = false
		stopped.emit()
		
##Checks which side is closest to the given Vector3. Vector3.UP is default, which will give the side that faces up. and returns that side.
func get_top_facing_side(comp_vector: Vector3 = Vector3.UP) -> void:
	var top_facing_side: Side = sides[0]

	for i in sides:
		if i.global_transform.basis.z.normalized().dot(comp_vector) >= top_facing_side.global_transform.basis.z.normalized().dot(comp_vector):
			top_facing_side = i

	current_side = top_facing_side
	has_rolled = true
