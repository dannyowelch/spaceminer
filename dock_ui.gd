class_name DockUI
extends Control

var main_ref: Node = null

@onready var info_label = $Panel/InfoLabel
@onready var cargo_display = $Panel/CargoDisplay
@onready var sell_button = $Panel/SellButton
@onready var upgrade1_button = $Panel/Upgrade1Button
@onready var upgrade2_button = $Panel/Upgrade2Button
@onready var upgrade3_button = $Panel/Upgrade3Button
@onready var continue_button = $Panel/ContinueButton

func _ready():
	size = Vector2(1280, 720)
	
	sell_button.pressed.connect(_on_sell_pressed)
	upgrade1_button.pressed.connect(_on_upgrade1_pressed)
	upgrade2_button.pressed.connect(_on_upgrade2_pressed)
	upgrade3_button.pressed.connect(_on_upgrade3_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	
	_update_display()

func _update_display():
	if not main_ref:
		return
	
	var cargo_filled = main_ref.cargo_grid.get_filled_slots()
	info_label.text = "STARBASE DOCK\nCredits: %d" % main_ref.credits
	
	_update_cargo_display()
	
	sell_button.text = "Sell All Ore"
	sell_button.disabled = cargo_filled == 0
	
	upgrade1_button.text = "Mining Beam Upgrade (150 CR)"
	upgrade1_button.disabled = main_ref.credits < 150
	
	upgrade2_button.text = "Cargo Hold Expansion (200 CR)"
	upgrade2_button.disabled = main_ref.credits < 200
	
	upgrade3_button.text = "Weapon System (300 CR)"
	upgrade3_button.disabled = main_ref.credits < 300 or main_ref.has_weapon

func _on_sell_pressed():
	var earned = main_ref.sell_all_ore()
	if main_ref.audio:
		main_ref.audio.play_sfx("sell")
	_update_display()

func _on_upgrade1_pressed():
	if main_ref.buy_upgrade("mining_beam", 150):
		if main_ref.audio:
			main_ref.audio.play_sfx("ui_ok")
		_update_display()
	else:
		if main_ref.audio:
			main_ref.audio.play_sfx("ui_deny")

func _on_upgrade2_pressed():
	if main_ref.buy_upgrade("cargo_hold", 200):
		if main_ref.audio:
			main_ref.audio.play_sfx("ui_ok")
		_update_display()
	else:
		if main_ref.audio:
			main_ref.audio.play_sfx("ui_deny")

func _on_upgrade3_pressed():
	if main_ref.buy_upgrade("weapon", 300):
		if main_ref.audio:
			main_ref.audio.play_sfx("ui_ok")
		_update_display()
	else:
		if main_ref.audio:
			main_ref.audio.play_sfx("ui_deny")

func _on_continue_pressed():
	main_ref._start_razor_reach()

func _update_cargo_display():
	if not cargo_display or not main_ref:
		return
	
	for child in cargo_display.get_children():
		child.queue_free()
	
	var ore_textures = {
		"common": load("res://sprites/ore_common.png"),
		"uncommon": load("res://sprites/ore_uncommon.png"),
		"rare": load("res://sprites/ore_rare.png")
	}
	
	var x_pos = 0
	for slot in main_ref.cargo_grid.slots:
		if slot.ore_type != "":
			var ore_icon = TextureRect.new()
			ore_icon.texture = ore_textures.get(slot.ore_type)
			ore_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ore_icon.custom_minimum_size = Vector2(24, 24)
			ore_icon.position = Vector2(x_pos, 0)
			cargo_display.add_child(ore_icon)
			
			var amount_label = Label.new()
			amount_label.text = "x%d" % slot.amount
			amount_label.position = Vector2(x_pos + 26, 4)
			amount_label.add_theme_font_size_override("font_size", 12)
			cargo_display.add_child(amount_label)
			
			x_pos += 60
