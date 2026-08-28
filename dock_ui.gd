class_name DockUI
extends Control

var main_ref: Node = null

@onready var info_label = $Panel/InfoLabel
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
	info_label.text = "STARBASE DOCK\nCredits: %d\nCargo: %d slots" % [main_ref.credits, cargo_filled]
	
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
	_update_display()

func _on_upgrade1_pressed():
	if main_ref.buy_upgrade("mining_beam", 150):
		_update_display()

func _on_upgrade2_pressed():
	if main_ref.buy_upgrade("cargo_hold", 200):
		_update_display()

func _on_upgrade3_pressed():
	if main_ref.buy_upgrade("weapon", 300):
		_update_display()

func _on_continue_pressed():
	main_ref._start_razor_reach()
