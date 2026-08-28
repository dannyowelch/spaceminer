class_name Asteroid
extends Node2D

var ore_remaining: int = 30
var rarity: String = "common"

func _ready():
	z_index = 5

func mine(power: int) -> int:
	var mined = mini(power, ore_remaining)
	ore_remaining -= mined
	if ore_remaining <= 0:
		queue_free()
	else:
		queue_redraw()
	return mined

func _draw():
	var size = 10 + (ore_remaining * 0.5)
	var color: Color
	match rarity:
		"common":
			color = Color(0.6, 0.6, 0.6)
		"uncommon":
			color = Color(0.7, 0.5, 0.3)
		"rare":
			color = Color(0.3, 0.7, 0.5)
	
	var points = PackedVector2Array([
		Vector2(-size, -size * 0.7),
		Vector2(-size * 0.5, -size),
		Vector2(size * 0.6, -size * 0.8),
		Vector2(size, -size * 0.2),
		Vector2(size * 0.7, size * 0.6),
		Vector2(size * 0.2, size),
		Vector2(-size * 0.6, size * 0.8),
		Vector2(-size * 0.9, size * 0.3)
	])
	
	draw_colored_polygon(points, color)
	var closed_points = PackedVector2Array(points)
	closed_points.append(points[0])
	draw_polyline(closed_points, color.lightened(0.2), 1.5)
