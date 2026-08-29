extends CanvasLayer

var main_ref: Node = null
var cargo_icons: Dictionary = {}

@onready var overlay: Sprite2D = $Overlay
@onready var hull_pips: Node2D = $HullPips
@onready var cargo_slots: Node2D = $CargoSlots
@onready var credits_value: Label = $CreditsValue

func _ready():
	var overlay_img = Image.load_from_file("res://sprites/hud_overlay.png")
	if overlay_img == null:
		push_error("Failed to load hud_overlay.png")
	else:
		var overlay_texture = ImageTexture.create_from_image(overlay_img)
		overlay.texture = overlay_texture
		overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var common_img = Image.load_from_file("res://sprites/asteroid_common.png")
	var uncommon_img = Image.load_from_file("res://sprites/asteroid_uncommon.png")
	var rare_img = Image.load_from_file("res://sprites/asteroid_rare.png")
	
	cargo_icons = {}
	if common_img:
		cargo_icons["common"] = ImageTexture.create_from_image(common_img)
	if uncommon_img:
		cargo_icons["uncommon"] = ImageTexture.create_from_image(uncommon_img)
	if rare_img:
		cargo_icons["rare"] = ImageTexture.create_from_image(rare_img)

func update_display(_hull: int, _max_hull: int, _fuel: int, _max_fuel: int, credits: int, _sector_name: String):
	if credits_value:
		credits_value.text = str(credits).pad_zeros(7)

func update_cargo(cargo_grid):
	for child in cargo_slots.get_children():
		child.queue_free()
	
	var start_x = 1023
	var start_y = 143
	var slot_size = 48
	var spacing = 62
	var cols = 3
	
	print("Cargo slot positions (cx, cy, w, h):")
	for i in range(cargo_grid.slots.size()):
		var slot = cargo_grid.slots[i]
		var row = i / cols
		var col = i % cols
		
		var cx = start_x + (col * spacing)
		var cy = start_y + (row * spacing)
		
		print("Slot %d: (%d, %d, %d, %d)" % [i, cx, cy, slot_size, slot_size])
		
		if slot.ore_type != "":
			var icon = Sprite2D.new()
			icon.texture = cargo_icons.get(slot.ore_type)
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon.position = Vector2(cx, cy)
			icon.scale = Vector2(slot_size / 96.0, slot_size / 96.0)
			cargo_slots.add_child(icon)
