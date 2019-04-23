extends RigidBody

const turn_torque = 20
const acc_force = 70
const linear_friction = 0.07

const blue_pixel_ref = "0d47a1"
const orange_pixel_ref = "f57f17"
const yellow_pixel_ref = "ffd600"

const k_p = 0.07
const k_i = 0
const k_d = 0

const orange_push_factor = 100

onready var node_hud_blue = get_node("/root/Scene/HUD/BlueIndicator")
onready var node_hud_yellow = get_node("/root/Scene/HUD/YellowIndicator")

func get_push():
	var img = get_viewport().get_texture().get_data()  # image is flipped in y
	img.lock()
	var blue_push = 0
	var orange_push = 0
	var yellow_push = 0
	for y in range(0, img.get_height() / 2, 8):
		for x in range(0, img.get_width(), 8):
			var pixel = img.get_pixel(x, y).to_html(false)
			if pixel == blue_pixel_ref:
				blue_push += x
			elif pixel == orange_pixel_ref:
				orange_push += 1
			elif pixel == yellow_pixel_ref:
				yellow_push += x - img.get_width()
	return [float(blue_push) / img.get_width(), float(orange_push), float(yellow_push) / img.get_width()]

func controller(blue_push, orange_push, yellow_push):
	var push = blue_push + yellow_push
	if orange_push > 0:
		push /= (orange_push * orange_push_factor)
	print(orange_push * orange_push_factor, ", ", push)
	return -push * k_p

func _physics_process(delta):
	## Check for cones
	var push = get_push()
	var input = controller(push[0], push[1], push[2])
	
	## Update HUD
	#node_hud_blue.set_position(Vector2(0, pixels[3] / 2) * 2 + Vector2(pixels[0].x, -pixels[0].y))
	#node_hud_yellow.set_position(Vector2(0, pixels[3] / 2) * 2 + Vector2(pixels[1].x, -pixels[1].y))


	## Local vectors
	var forward = get_transform().basis.x
	var up = get_transform().basis.y
	var left = get_transform().basis.z
	
	## Input
	#apply_central_impulse(forward * Input.get_action_strength("acc") * delta * acc_force)
	apply_central_impulse(forward * delta * acc_force)
	#apply_torque_impulse(up * (Input.get_action_strength("left") - Input.get_action_strength("right")) * delta * turn_torque)
	apply_torque_impulse(up * input * delta * turn_torque)

	## Friction forces
	var v = get_linear_velocity()
	apply_central_impulse(-left * v.project(left).length() * delta * 60 * sign(v.dot(left)))
	apply_central_impulse(-linear_velocity * linear_friction)
