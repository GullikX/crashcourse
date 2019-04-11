extends RigidBody

const turn_torque = 80
const acc_force = 120

const blue_pixel_ref = "036eaf"
const yellow_pixel_ref = "85982d"

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
				return Vector2(blue_pixel, yellow_pixel)
	return Vector2(blue_pixel, yellow_pixel)

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
	
	var cones = get_cones()
	var blue_cone = cones.x
	var yellow_cone = cones.y
	print(str(blue_cone) + ", " + str(yellow_cone))
