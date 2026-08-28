class_name Ship
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var rotation_speed: float = 3.0
var thrust_power: float = 200.0
var max_speed: float = 400.0
var drag: float = 0.98

var main_ref: Node = null

@onready var sprite: Sprite2D = $Sprite2D

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
		
		if main_ref and main_ref.audio:
			main_ref.audio.play_sfx("thrust")
	else:
		if main_ref and main_ref.audio:
			main_ref.audio.stop_thrust()
	
	velocity *= drag
	
	position += velocity * delta
	
	position.x = clampf(position.x, 280, 1000)
	position.y = clampf(position.y, 0, 720)
	
	if Input.is_action_pressed("mine") and main_ref:
		main_ref.try_mine()
	
	if Input.is_action_just_pressed("fire") and main_ref and main_ref.has_weapon:
		_fire_weapon()

func _fire_weapon():
	if main_ref and main_ref.audio:
		main_ref.audio.play_sfx("fire")
	var bullet = preload("res://bullet.tscn").instantiate()
	bullet.position = position
	bullet.rotation = rotation
	bullet.velocity = Vector2(cos(rotation - PI/2), sin(rotation - PI/2)) * 500 + velocity
	bullet.damage = main_ref.weapon_damage
	bullet.is_player = true
	get_parent().add_child(bullet)
