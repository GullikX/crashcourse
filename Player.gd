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

const blue_push_factor = -0.07
const yellow_push_factor = -0.07
const orange_push_factor = 0.01
const hud_factor = 20

onready var node_hud_blue = get_node("/root/Scene/HUD/BlueIndicator")
onready var node_hud_yellow = get_node("/root/Scene/HUD/YellowIndicator")
onready var node_hud_orange_left = get_node("/root/Scene/HUD/OrangeIndicatorLeft")
onready var node_hud_orange_right = get_node("/root/Scene/HUD/OrangeIndicatorRight")
onready var node_hud_total_left = get_node("/root/Scene/HUD/TotalIndicatorLeft")
onready var node_hud_total_right = get_node("/root/Scene/HUD/TotalIndicatorRight")

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
				orange_push += x - img.get_width() / 2
			elif pixel == yellow_pixel_ref:
				yellow_push += x - img.get_width()
	return [float(blue_push) / img.get_width(), float(orange_push) / img.get_width(), float(yellow_push) / img.get_width()]

func controller(blue_push, orange_push, yellow_push):
	return blue_push_factor * blue_push + yellow_push_factor * yellow_push + orange_push_factor * orange_push

func _physics_process(delta):
	## Check for cones
	var push = get_push()
	var input = controller(push[0], push[1], push[2])
	
	## Update HUD
	var anchor_x = get_viewport().size.x / 2
	node_hud_blue.set_position(Vector2(anchor_x, 8))
	node_hud_blue.set_size(Vector2(-hud_factor * blue_push_factor * push[0], 8))

	node_hud_yellow.set_position(Vector2(anchor_x, 8))
	node_hud_yellow.set_size(Vector2(hud_factor * yellow_push_factor * push[2], 8))

	node_hud_orange_left.set_position(Vector2(anchor_x, 20))
	node_hud_orange_right.set_position(Vector2(anchor_x, 20))
	if orange_push_factor * push[1] > 0:
		node_hud_orange_left.set_size(Vector2(hud_factor * orange_push_factor * push[1], 8))
		node_hud_orange_right.set_size(Vector2(0, 8))
	else:
		node_hud_orange_right.set_size(Vector2(-hud_factor * orange_push_factor * push[1], 8))
		node_hud_orange_left.set_size(Vector2(0, 8))

	node_hud_total_left.set_position(Vector2(anchor_x, 4))
	node_hud_total_right.set_position(Vector2(anchor_x, 4))
	if blue_push_factor * push[0] + yellow_push_factor * push[2] + orange_push_factor * push[1] > 0:
		node_hud_total_left.set_size(Vector2(hud_factor * (blue_push_factor * push[0] + yellow_push_factor * push[2] + orange_push_factor * push[1]), 28))
		node_hud_total_right.set_size(Vector2(0, 28))
	else:
		node_hud_total_right.set_size(Vector2(-hud_factor * (blue_push_factor * push[0] + yellow_push_factor * push[2] + orange_push_factor * push[1]), 28))
		node_hud_total_left.set_size(Vector2(0, 28))


	## Local vectors
	var forward = get_transform().basis.x
	var up = get_transform().basis.y
	var left = get_transform().basis.z
	
	## Uncomment for autonomous drive
	apply_central_impulse(forward * delta * acc_force)
	apply_torque_impulse(up * input * delta * turn_torque)
	
	## Uncomment for manual drive
	#apply_central_impulse(forward * Input.get_action_strength("acc") * delta * acc_force)
	#apply_torque_impulse(up * (Input.get_action_strength("left") - Input.get_action_strength("right")) * delta * turn_torque)

	## Friction forces
	var v = get_linear_velocity()
	apply_central_impulse(-left * v.project(left).length() * delta * 60 * sign(v.dot(left)))
	apply_central_impulse(-linear_velocity * linear_friction)
