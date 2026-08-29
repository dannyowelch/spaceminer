class_name Asteroid
extends Node2D

var ore_remaining: int = 30
var rarity: String = "common"
var size: String = "small"

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	z_index = 5
	_update_sprite()

func _update_sprite():
	if sprite:
		var texture_path = ""
		match size:
			"small":
				texture_path = "res://sprites/asteroid_32.png"
			"medium":
				texture_path = "res://sprites/asteroid_56.png"
			"large":
				texture_path = "res://sprites/asteroid_88.png"
		
		var img = Image.load_from_file(texture_path)
		if img == null:
			push_error("Failed to load " + texture_path)
		else:
			var texture = ImageTexture.create_from_image(img)
			sprite.texture = texture
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func get_radius() -> float:
	match size:
		"small":
			return 16.0
		"medium":
			return 28.0
		"large":
			return 44.0
	return 20.0

func mine(power: int) -> int:
	var mined = mini(power, ore_remaining)
	ore_remaining -= mined
	if ore_remaining <= 0:
		queue_free()
	else:
		var scale_factor = 0.5 + (ore_remaining / 60.0)
		if sprite:
			sprite.scale = Vector2(scale_factor, scale_factor)
	return mined
