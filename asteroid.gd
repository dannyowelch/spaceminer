class_name Asteroid
extends Node2D

var ore_remaining: int = 30
var rarity: String = "common"

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	z_index = 5
	_update_sprite()

func _update_sprite():
	if sprite:
		var texture_path = ""
		match rarity:
			"common":
				texture_path = "res://sprites/asteroid_common.png"
			"uncommon":
				texture_path = "res://sprites/asteroid_uncommon.png"
			"rare":
				texture_path = "res://sprites/asteroid_rare.png"
		
		var img = Image.load_from_file(texture_path)
		if img == null:
			push_error("Failed to load " + texture_path)
		else:
			var texture = ImageTexture.create_from_image(img)
			sprite.texture = texture
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

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
