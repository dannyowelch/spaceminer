class_name CargoGrid
extends RefCounted

class Slot:
	var ore_type: String = ""
	var amount: int = 0

var slots: Array[Slot] = []
var capacity: int = 12

func initialize(size: int):
	capacity = size
	slots.clear()
	for i in range(capacity):
		slots.append(Slot.new())

func expand(new_capacity: int):
	var old_capacity = capacity
	capacity = new_capacity
	for i in range(capacity - old_capacity):
		slots.append(Slot.new())

func add_ore(ore_type: String, amount: int) -> int:
	var remaining = amount
	
	for slot in slots:
		if slot.ore_type == ore_type and slot.amount < 10:
			var space = 10 - slot.amount
			var to_add = mini(space, remaining)
			slot.amount += to_add
			remaining -= to_add
			if remaining <= 0:
				return 0
	
	for slot in slots:
		if slot.ore_type == "":
			slot.ore_type = ore_type
			var to_add = mini(10, remaining)
			slot.amount = to_add
			remaining -= to_add
			if remaining <= 0:
				return 0
	
	return remaining

func get_filled_slots() -> int:
	var filled = 0
	for slot in slots:
		if slot.ore_type != "":
			filled += 1
	return filled

func clear():
	for slot in slots:
		slot.ore_type = ""
		slot.amount = 0
