class_name Starbase
extends Node2D

func _ready():
	z_index = 5

func _draw():
	draw_circle(Vector2.ZERO, 40, Color(0.4, 0.4, 0.5))
	draw_arc(Vector2.ZERO, 40, 0, TAU, 32, Color(0.6, 0.6, 0.7), 3.0)
	
	for i in range(4):
		var angle = i * PI / 2
		var start = Vector2(cos(angle), sin(angle)) * 30
		var end = Vector2(cos(angle), sin(angle)) * 50
		draw_line(start, end, Color(0.7, 0.7, 0.8), 3.0)
