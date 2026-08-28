class_name Pirate
extends Node2D

var hull: int = 8
var velocity: Vector2 = Vector2.ZERO
var thrust_power: float = 150.0
var max_speed: float = 300.0
var rotation_speed: float = 2.5
var drag: float = 0.97

var main_ref: Node = null
var fire_timer: float = 0
var fire_cooldown: float = 1.5

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	z_index = 10

func _process(delta):
	if main_ref and main_ref.player_ship:
		var target = main_ref.player_ship.position
		var to_target = target - position
		var desired_angle = to_target.angle() + PI/2
		
		var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
		rotation += sign(angle_diff) * rotation_speed * delta * 0.5
		
		if abs(angle_diff) < 0.5:
			var thrust_dir = Vector2(cos(rotation - PI/2), sin(rotation - PI/2))
			velocity += thrust_dir * thrust_power * delta
			
			if velocity.length() > max_speed:
				velocity = velocity.normalized() * max_speed
		
		velocity *= drag
		position += velocity * delta
		
		fire_timer -= delta
		if fire_timer <= 0 and to_target.length() < 400:
			_fire_weapon()
			fire_timer = fire_cooldown

func _fire_weapon():
	var bullet = preload("res://bullet.tscn").instantiate()
	bullet.position = position
	bullet.rotation = rotation
	bullet.velocity = Vector2(cos(rotation - PI/2), sin(rotation - PI/2)) * 400 + velocity
	bullet.damage = 2
	bullet.is_player = false
	get_parent().add_child(bullet)

func take_damage(amount: int):
	hull -= amount
	if hull <= 0:
		queue_free()
