class_name Bullet
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 1
var lifetime: float = 2.0
var is_player: bool = true

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	z_index = 15
	if sprite:
		if is_player:
			sprite.texture = load("res://sprites/bullet_player.png")
		else:
			sprite.texture = load("res://sprites/bullet_pirate.png")

func _process(delta):
	position += velocity * delta
	lifetime -= delta
	
	if lifetime <= 0:
		queue_free()
		return
	
	_check_collisions()

func _check_collisions():
	var parent = get_parent()
	if not parent:
		return
	
	if is_player:
		for child in parent.get_children():
			if child.has_method("take_damage") and child != self:
				var distance = position.distance_to(child.position)
				if distance < 15:
					child.take_damage(damage)
					queue_free()
					return
	else:
		for child in parent.get_children():
			if child.get_class() == "Node2D" and child.get_script() != null:
				var script_path = child.get_script().resource_path
				if script_path == "res://ship.gd" and child == parent.get_parent().player_ship:
					var distance = position.distance_to(child.position)
					if distance < 15:
						parent.get_parent().damage_hull(damage)
						queue_free()
						return
