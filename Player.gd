extends RigidBody

const turn_torque = 80
const acc_force = 70
const linear_friction = 0.07

const blue_pixel_ref = "0d47a1"
const yellow_pixel_ref = "ffd600"

const k_p = 1.6
const k_i = 0
const k_d = 0

onready var node_hud_blue = get_node("/root/Scene/HUD/BlueIndicator")
onready var node_hud_yellow = get_node("/root/Scene/HUD/YellowIndicator")

func get_cones():
	var img = get_viewport().get_texture().get_data()  # image is flipped in y
	img.lock()
	var blue_pixel = Vector2(-1, -1)
	var yellow_pixel = Vector2(-1, -1)
	for y in range(0, img.get_height() / 2, 8):
		for x in range(0, img.get_width(), 8):
			var pixel = img.get_pixel(x, y).to_html(false)
			if blue_pixel.x == -1 and pixel == blue_pixel_ref:
				blue_pixel = Vector2(x, y)
			elif yellow_pixel.x == -1 and pixel == yellow_pixel_ref:
				yellow_pixel = Vector2(x, y)
			if blue_pixel.x != -1 and yellow_pixel.x != -1:
				return [blue_pixel, yellow_pixel, img.get_width(), img.get_height()]
	return [blue_pixel, yellow_pixel, img.get_width(), img.get_height()]

func controller(blue_pixel, yellow_pixel, width):
	var error = 0.5 - (blue_pixel.x + yellow_pixel.x) / 2 / width
	print((blue_pixel.x + yellow_pixel.x) / 2 / width)
	return error * k_p

func _physics_process(delta):
	## Check for cones
	var pixels = get_cones()
	var input = controller(pixels[0], pixels[1], pixels[2])
	
	## Update HUD
	node_hud_blue.set_position(Vector2(0, pixels[3] / 2) * 2 + Vector2(pixels[0].x, -pixels[0].y))
	node_hud_yellow.set_position(Vector2(0, pixels[3] / 2) * 2 + Vector2(pixels[1].x, -pixels[1].y))


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
