extends RigidBody

const turn_torque = 20
const acc_force = 70
const linear_friction = 0.07

const blue_pixel_ref = "0d47a1"
const yellow_pixel_ref = "ffd600"

const k_p = 6.4
const k_i = 0
const k_d = 0

onready var node_hud = get_node("/root/Scene/HUD")


func get_cones():
	var img = get_viewport().get_texture().get_data()  # image is flipped in y
	img.lock()
	var blue_pixels = PoolVector2Array()
	var yellow_pixels = PoolVector2Array()
	for x in range(0, img.get_width(), 8):
		for y in range(0, img.get_height() / 2, 8):
			var pixel = img.get_pixel(x, y).to_html(false)
			if pixel == blue_pixel_ref:
				blue_pixels.append(Vector2(x, y))
			elif pixel == yellow_pixel_ref:
				yellow_pixels.append(Vector2(x, y))
	return [blue_pixels, yellow_pixels, img.get_width(), img.get_height()]


func array_multiply(a, b):
	var p = Array()
	for i in range(len(a)):
		p.append(a[i] * b[i])
	return p


func mean(values):
	if len(values) == 0:
		return 0
	return sum(values) / len(values)


func sum(values):
	var s = 0
	for val in values:
		s += val
	return s

func minus(array, number):
	var result = Array()
	for i in range(len(array)):
		result.append(array[i] - number)
	return result


func linear_fit(x_values, y_values):
	var n = len(x_values)
	if n == 0:
		return Vector2()

	var mean_x = mean(x_values)
	var mean_y = mean(y_values)

	var SS_xy = sum(minus(array_multiply(y_values, x_values), n * mean_x * mean_y))
	var SS_xx = sum(minus(array_multiply(x_values, x_values), n * mean_x * mean_x))
	
	if SS_xx == 0:
		return Vector2()
	var b1 = SS_xy / SS_xx
	var b0 = mean_y - b1 * mean_x
	
	return Vector2(b0, b1)


func controller(blue_pixel, yellow_pixel, width):
	var error = 0.5 - (blue_pixel.x + yellow_pixel.x) / 2 / width
	return error * k_p


func _physics_process(delta):
	## Check for cones
	var pixels = get_cones()
	var blue_pixels = pixels[0]
	var yellow_pixels = pixels[1]
	var img_width = pixels[2]
	var img_height = pixels[3]

	var blue_x = Array()
	var blue_y = Array()
	for pixel in blue_pixels:
		blue_x.append(pixel[0])
		blue_y.append(pixel[1])
	var fit_blue = linear_fit(blue_x, blue_y)
	print(fit_blue)

	var yellow_x = Array()
	var yellow_y = Array()
	for pixel in yellow_pixels:
		yellow_x.append(pixel[0])
		yellow_y.append(pixel[1])
	var fit_yellow = linear_fit(yellow_x, yellow_y)
	#print(fit_blue, fit_yellow)
	#var input = controller(pixels[0], pixels[1], pixels[2])

	## Update HUD
	if fit_blue[1] != 0:
		node_hud.green_line1 = Vector2(-fit_blue[0] / fit_blue[1], 0)
		node_hud.green_line2 = Vector2((img_height * 8 - fit_blue[0]) / fit_blue[1], img_height * 8)
	if fit_yellow[1] != 0:
		node_hud.red_line1 = Vector2(-fit_yellow[0] / fit_yellow[1], 0)
		node_hud.red_line2 = Vector2((img_height * 8 - fit_yellow[0]) / fit_yellow[1], img_height * 8)
	


	## Local vectors
	var forward = get_transform().basis.x
	var up = get_transform().basis.y
	var left = get_transform().basis.z
	
	## Input
	apply_central_impulse(forward * Input.get_action_strength("acc") * delta * acc_force)
	#apply_central_impulse(forward * delta * acc_force)
	apply_torque_impulse(up * (Input.get_action_strength("left") - Input.get_action_strength("right")) * delta * turn_torque)
	#apply_torque_impulse(up * input * delta * turn_torque)

	## Friction forces
	var v = get_linear_velocity()
	apply_central_impulse(-left * v.project(left).length() * delta * 60 * sign(v.dot(left)))
	apply_central_impulse(-linear_velocity * linear_friction)
