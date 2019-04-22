extends Node2D

var green_line1 = Vector2()
var green_line2 = Vector2()
var red_line1 = Vector2()
var red_line2 = Vector2()


func _ready():
	pass # Replace with function body.


func _draw():
	draw_line(green_line1, green_line2, Color(0, 255, 0), 1)
	draw_line(red_line1, red_line2, Color(255, 0, 0), 1)


func _process(delta):
	update()
