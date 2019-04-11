extends Camera

const smooth_speed = 10

var smooth_camera_pos = Vector3()
onready var node_player = get_node("/root/Scene/Player")
onready var node_anchor = get_node("/root/Scene/Player/CameraAnchor")


func _process(delta):
	## Set target position to anchor, and target rotation towards the player
	var target_pos = node_anchor.get_global_transform().origin
	var look_dir = node_player.get_global_transform().origin

	## Make the camera move to the target position in a smooth manner
	smooth_camera_pos = smooth_camera_pos.linear_interpolate(target_pos, smooth_speed * delta)

	## Do not want camera beneath the ground
	if smooth_camera_pos.y < 2:
		smooth_camera_pos.y = 2

	## Set translation and rotation
	set_translation(smooth_camera_pos)
	look_at(look_dir, Vector3(0,1,0))