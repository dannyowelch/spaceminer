class_name Starbase
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	z_index = 5
	
	var img = Image.load_from_file("res://sprites/starbase.png")
	if img == null:
		push_error("Failed to load starbase.png")
	else:
		var texture = ImageTexture.create_from_image(img)
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
