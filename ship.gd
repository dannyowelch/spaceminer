class_name Ship
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var rotation_speed: float = 3.0
var thrust_power: float = 200.0
var max_speed: float = 400.0
var drag: float = 0.98

var main_ref: Node = null
var mining_beam_length: float = 120.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var mining_beam: Line2D = $MiningBeam

func _ready():
	z_index = 10
	
	var img = Image.load_from_file("res://sprites/ship.png")
	if img == null:
		push_error("Failed to load ship.png")
	else:
		var texture = ImageTexture.create_from_image(img)
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

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
	
	position.x = clampf(position.x, 50, 1400)
	position.y = clampf(position.y, 50, 1000)
	
	if Input.is_action_pressed("mine") and main_ref:
		_update_mining_beam()
		main_ref.try_mine()
	else:
		mining_beam.visible = false
	
	if Input.is_action_just_pressed("fire") and main_ref and main_ref.has_weapon:
		_fire_weapon()

func get_scoop_position() -> Vector2:
	var facing = Vector2(cos(rotation - PI/2), sin(rotation - PI/2))
	var scoop_offset = 64.0
	return position + facing * scoop_offset

func get_facing() -> Vector2:
	return Vector2(cos(rotation - PI/2), sin(rotation - PI/2))

func _update_mining_beam():
	mining_beam.visible = true
	mining_beam.clear_points()
	mining_beam.add_point(Vector2(0, -64))
	mining_beam.add_point(Vector2(0, -184))

func _fire_weapon():
	if main_ref and main_ref.audio:
		main_ref.audio.play_sfx("fire")
	var bullet = preload("res://bullet.tscn").instantiate()
	bullet.position = get_scoop_position()
	bullet.rotation = rotation
	bullet.velocity = Vector2(cos(rotation - PI/2), sin(rotation - PI/2)) * 500 + velocity
	bullet.damage = main_ref.weapon_damage
	bullet.is_player = true
	get_parent().add_child(bullet)
