extends RigidBody

const turn_torque = 20
const acc_force = 70
const linear_friction = 0.07

const blue_pixel_ref = "0d47a1"
const yellow_pixel_ref = "ffd600"
const orange_pixel_ref = "f57f17"

const push_factor = 0.07
const hud_gain = 30

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
	var yellow_push = 0
	var orange_push = 0
	for y in range(0, img.get_height() / 2, 8):
		for x in range(0, img.get_width(), 8):
			var pixel = img.get_pixel(x, y).to_html(false)
			if pixel == blue_pixel_ref:
				blue_push += img.get_width() - x
			elif pixel == orange_pixel_ref:
				if x > img.get_width() / 2:
					blue_push += img.get_width() - x
					orange_push -= img.get_width() - x  # used only for HUD indicator
				else:
					yellow_push += x
					orange_push += x  # used only for HUD indicator
			elif pixel == yellow_pixel_ref:
				yellow_push += x
	return [float(blue_push) / img.get_width(), float(yellow_push) / img.get_width(), float(orange_push) / img.get_width()]

func controller(blue_push, yellow_push):
	return push_factor * (blue_push - yellow_push)

func _physics_process(delta):
	## Check for cones
	var push = get_push()
	var input = controller(push[0], push[1])
	
	## Update HUD
	var anchor_x = get_viewport().size.x / 2
	node_hud_blue.set_position(Vector2(anchor_x, 8))
	node_hud_blue.set_size(Vector2(hud_gain * push_factor * push[0], 8))

	node_hud_yellow.set_position(Vector2(anchor_x, 8))
	node_hud_yellow.set_size(Vector2(hud_gain * push_factor * push[1], 8))
	
	node_hud_orange_left.set_position(Vector2(anchor_x, 10))
	node_hud_orange_right.set_position(Vector2(anchor_x, 10))
	if push_factor * push[2] < 0:
		node_hud_orange_left.set_size(Vector2(-hud_gain * (push_factor * push[2]), 4))
		node_hud_orange_right.set_size(Vector2(0, 4))
	else:
		node_hud_orange_right.set_size(Vector2(hud_gain * (push_factor * push[2]), 4))
		node_hud_orange_left.set_size(Vector2(0, 4))

	node_hud_total_left.set_position(Vector2(anchor_x, 4))
	node_hud_total_right.set_position(Vector2(anchor_x, 4))
	if push_factor * (push[0] - push[1]) > 0:
		node_hud_total_left.set_size(Vector2(hud_gain * push_factor * (push[0] - push[1]), 16))
		node_hud_total_right.set_size(Vector2(0, 16))
	else:
		node_hud_total_right.set_size(Vector2(-hud_gain * push_factor * (push[0] - push[1]), 16))
		node_hud_total_left.set_size(Vector2(0, 16))


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
