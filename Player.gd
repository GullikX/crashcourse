extends RigidBody

const turn_torque = 30
const acc_force = 100

func _ready():
	pass

func _physics_process(delta):
	apply_central_impulse(get_transform().basis.x * Input.get_action_strength("acc") * delta * acc_force)
	apply_torque_impulse(get_transform().basis.y * (Input.get_action_strength("left") - Input.get_action_strength("right")) * delta * turn_torque)
