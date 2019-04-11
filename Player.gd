extends RigidBody

const turn_torque = 80
const acc_force = 30
const linear_friction = 0.07

const blue_pixel_ref = "036eaf"
const yellow_pixel_ref = "85982d"

const k_p = 0.009
const k_i = 0
const k_d = 0

func get_cones():
	var img = get_viewport().get_texture().get_data()  # image is flipped in y
	img.shrink_x2()
	img.shrink_x2()
	img.shrink_x2()
	img.lock()
	var output = ""
	var blue_pixel = -1
	var yellow_pixel = -1
	for y in range(0, img.get_height() / 2):
		for x in range(img.get_width()):
			var pixel = img.get_pixel(x, y).to_html(false)
			if pixel == blue_pixel_ref:
				blue_pixel = x
			elif pixel == yellow_pixel_ref:
				yellow_pixel = x
			if blue_pixel != -1 and yellow_pixel != -1:
				return Vector3(blue_pixel, yellow_pixel, img.get_width())
	return Vector3(blue_pixel, yellow_pixel, img.get_width())

func controller(blue_pixel, yellow_pixel, width):
	var error = width / 2 - (blue_pixel + yellow_pixel) / 2
	return error * k_p

func _physics_process(delta):
	## Check for cones
	var cones = get_cones()
	var input = controller(cones.x, cones.y, cones.z)

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
	print(linear_velocity.length())
