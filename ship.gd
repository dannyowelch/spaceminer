class_name Ship
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var rotation_speed: float = 3.0
var thrust_power: float = 200.0
var max_speed: float = 400.0
var drag: float = 0.98

var main_ref: Node = null

func _ready():
	z_index = 10

func _process(delta):
	if Input.is_action_pressed("rotate_left"):
		rotation -= rotation_speed * delta
	if Input.is_action_pressed("rotate_right"):
		rotation += rotation_speed * delta
	
	if Input.is_action_pressed("thrust"):
		var thrust_dir = Vector2(cos(rotation - PI/2), sin(rotation - PI/2))
		velocity += thrust_dir * thrust_power * delta
		
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	
	velocity *= drag
	
	position += velocity * delta
	
	position.x = clampf(position.x, 280, 1000)
	position.y = clampf(position.y, 0, 720)
	
	if Input.is_action_pressed("mine") and main_ref:
		main_ref.try_mine()
	
	if Input.is_action_just_pressed("fire") and main_ref and main_ref.has_weapon:
		_fire_weapon()

func _fire_weapon():
	var bullet = preload("res://bullet.tscn").instantiate()
	bullet.position = position
	bullet.rotation = rotation
	bullet.velocity = Vector2(cos(rotation - PI/2), sin(rotation - PI/2)) * 500 + velocity
	bullet.damage = main_ref.weapon_damage
	bullet.is_player = true
	get_parent().add_child(bullet)

func _draw():
	var points = PackedVector2Array([
		Vector2(0, -12),
		Vector2(-8, 12),
		Vector2(0, 6),
		Vector2(8, 12)
	])
	draw_colored_polygon(points, Color(0.3, 0.6, 0.9))
	var closed_points = PackedVector2Array(points)
	closed_points.append(points[0])
	draw_polyline(closed_points, Color(0.5, 0.8, 1.0), 2.0)
