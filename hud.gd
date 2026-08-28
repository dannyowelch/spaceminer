class_name HUD
extends CanvasLayer

@onready var hull_label = $LeftPanel/HullLabel
@onready var fuel_label = $LeftPanel/FuelLabel
@onready var credits_label = $RightPanel/CreditsLabel
@onready var cargo_label = $RightPanel/CargoLabel

func update_display(hull: int, max_hull: int, fuel: int, max_fuel: int, credits: int, cargo_filled: int):
	hull_label.text = "HULL: " + _make_pips(hull, max_hull)
	fuel_label.text = "FUEL: %d/%d" % [fuel, max_fuel]
	credits_label.text = "CR: %d" % credits
	cargo_label.text = "CARGO: %d" % cargo_filled

func _make_pips(current: int, maximum: int) -> String:
	var result = ""
	for i in range(maximum):
		if i < current:
			result += "■"
		else:
			result += "□"
	return result
