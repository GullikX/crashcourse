extends RigidBody

const turn_torque = 80
const acc_force = 120

func _ready():
	pass

func _physics_process(delta):
	## Local vectors
	var forward = get_transform().basis.x
	var up = get_transform().basis.y
	var left = get_transform().basis.z
	
	## Input
	apply_central_impulse(forward * Input.get_action_strength("acc") * delta * acc_force)
	apply_torque_impulse(up * (Input.get_action_strength("left") - Input.get_action_strength("right")) * delta * turn_torque)
	
	## Sideways forces
	var v = get_linear_velocity()
	apply_central_impulse(-left * v.project(left).length() * delta * 60 * sign(v.dot(left)))
	print(v.project(left))
