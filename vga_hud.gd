extends CanvasLayer

var main_ref: Node = null
var ore_icons: Dictionary = {}

@onready var overlay: Sprite2D = $Overlay
@onready var hull_pips: Node2D = $HullPips
@onready var cargo_slots: Node2D = $CargoSlots
@onready var credits_label: Label = $CreditsLabel
@onready var sector_label: Label = $SectorLabel

func _ready():
	ore_icons = {
		"common": load("res://sprites/ore_common.png"),
		"uncommon": load("res://sprites/ore_uncommon.png"),
		"rare": load("res://sprites/ore_rare.png")
	}

func update_display(hull: int, max_hull: int, _fuel: int, _max_fuel: int, credits: int, sector_name: String):
	_update_hull_pips(hull, max_hull)
	_update_credits(credits)
	_update_sector(sector_name)

func _update_hull_pips(current: int, maximum: int):
	for child in hull_pips.get_children():
		child.queue_free()
	
	var start_x = 25
	var start_y = 290
	var pip_size = 10
	var spacing = 12
	
	for i in range(maximum):
		var pip = ColorRect.new()
		pip.custom_minimum_size = Vector2(pip_size, pip_size)
		pip.position = Vector2(start_x + (i * spacing), start_y)
		pip.color = Color(0, 1, 0, 1) if i < current else Color(0.2, 0.3, 0.2, 1)
		hull_pips.add_child(pip)

func _update_credits(amount: int):
	credits_label.text = str(amount).pad_zeros(7)

func _update_sector(name: String):
	sector_label.text = name

func update_cargo(cargo_grid):
	for child in cargo_slots.get_children():
		child.queue_free()
	
	var start_x = 1135
	var start_y = 120
	var slot_size = 40
	var spacing = 45
	var cols = 3
	
	for i in range(cargo_grid.slots.size()):
		var slot = cargo_grid.slots[i]
		var row = i / cols
		var col = i % cols
		
		var x = start_x + (col * spacing)
		var y = start_y + (row * spacing)
		
		if slot.ore_type != "":
			var icon = TextureRect.new()
			icon.texture = ore_icons.get(slot.ore_type)
			icon.position = Vector2(x, y)
			icon.custom_minimum_size = Vector2(slot_size, slot_size)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cargo_slots.add_child(icon)
