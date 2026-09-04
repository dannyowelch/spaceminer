extends CanvasLayer

var main_ref: Node = null
var cargo_icons: Dictionary = {}
var map_visible: bool = false

@onready var overlay: Sprite2D = $Overlay
@onready var credits_label: Label = $CreditsLabel
@onready var radar_dots: Node2D = $RadarDots
@onready var cargo_list: Node2D = $CargoList
@onready var galactic_map: ColorRect = $GalacticMap
@onready var dust_belt_node: ColorRect = $GalacticMap/DustBeltNode
@onready var razor_reach_node: ColorRect = $GalacticMap/RazorReachNode

func _ready():
	var overlay_img = Image.load_from_file("res://sprites/hud_overlay.png")
	if overlay_img:
		overlay.texture = ImageTexture.create_from_image(overlay_img)
		overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var ore_common_img = Image.load_from_file("res://sprites/ore_common.png")
	var ore_uncommon_img = Image.load_from_file("res://sprites/ore_uncommon.png")
	var ore_rare_img = Image.load_from_file("res://sprites/ore_rare.png")
	
	cargo_icons = {}
	if ore_common_img:
		cargo_icons["common"] = ImageTexture.create_from_image(ore_common_img)
	if ore_uncommon_img:
		cargo_icons["uncommon"] = ImageTexture.create_from_image(ore_uncommon_img)
	if ore_rare_img:
		cargo_icons["rare"] = ImageTexture.create_from_image(ore_rare_img)
	
	if not ore_common_img:
		var common_img = Image.load_from_file("res://sprites/asteroid_common.png")
		var uncommon_img = Image.load_from_file("res://sprites/asteroid_uncommon.png")
		var rare_img = Image.load_from_file("res://sprites/asteroid_rare.png")
		if common_img:
			cargo_icons["common"] = ImageTexture.create_from_image(common_img)
		if uncommon_img:
			cargo_icons["uncommon"] = ImageTexture.create_from_image(uncommon_img)
		if rare_img:
			cargo_icons["rare"] = ImageTexture.create_from_image(rare_img)

func _process(_delta):
	if Input.is_action_just_pressed("toggle_map"):
		map_visible = !map_visible
		galactic_map.visible = map_visible

func _input(event):
	if map_visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = event.position
		
		var dust_rect = Rect2(dust_belt_node.global_position, dust_belt_node.size)
		var razor_rect = Rect2(razor_reach_node.global_position, razor_reach_node.size)
		
		if dust_rect.has_point(mouse_pos) and main_ref:
			if main_ref.mode != main_ref.Mode.DUST_BELT and main_ref.fuel >= 2:
				main_ref.fuel -= 2
				main_ref._start_dust_belt()
				map_visible = false
				galactic_map.visible = false
		elif razor_rect.has_point(mouse_pos) and main_ref:
			if main_ref.mode != main_ref.Mode.RAZOR_REACH and main_ref.fuel >= 2:
				main_ref.fuel -= 2
				main_ref._start_razor_reach()
				map_visible = false
				galactic_map.visible = false

func update_display(hull: int, max_hull: int, fuel: int, max_fuel: int, credits: int, sector_name: String):
	credits_label.text = "%07d" % credits

func update_cargo(cargo_grid):
	for child in cargo_list.get_children():
		child.queue_free()
	
	var cargo_items = []
	for slot in cargo_grid.slots:
		if slot.ore_type != "":
			var found = false
			for item in cargo_items:
				if item.ore_type == slot.ore_type:
					item.amount += slot.amount
					found = true
					break
			if not found:
				cargo_items.append({"ore_type": slot.ore_type, "amount": slot.amount})
	
	cargo_items.sort_custom(func(a, b): return a.amount > b.amount)
	
	var row_height = 63
	var start_y = 120
	
	for i in range(min(cargo_items.size(), 12)):
		var item = cargo_items[i]
		var y_pos = start_y + (i * row_height)
		
		if cargo_icons.has(item.ore_type):
			var icon = Sprite2D.new()
			icon.texture = cargo_icons[item.ore_type]
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon.position = Vector2(1640, y_pos)
			icon.scale = Vector2(1.0, 1.0)
			cargo_list.add_child(icon)
		
		var name_label = Label.new()
		name_label.position = Vector2(1670, y_pos - 12)
		name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.text = item.ore_type.to_upper()
		cargo_list.add_child(name_label)
		
		var qty_label = Label.new()
		qty_label.position = Vector2(1850, y_pos - 12)
		qty_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		qty_label.add_theme_font_size_override("font_size", 12)
		qty_label.text = "x%d" % item.amount
		cargo_list.add_child(qty_label)

func update_radar(player_pos: Vector2, world_objects: Array, scanner_range: float, scanner_complexity: int):
	for child in radar_dots.get_children():
		child.queue_free()
	
	var radar_center = Vector2(140, 920)
	var radar_radius = 115.0
	var world_to_radar_scale = radar_radius / scanner_range
	
	for obj in world_objects:
		if not is_instance_valid(obj):
			continue
		
		var offset = obj.position - player_pos
		var distance = offset.length()
		
		if distance <= scanner_range and distance > 1:
			var is_station_or_planet = obj.is_in_group("station") or obj.is_in_group("planet")
			var is_asteroid = obj.is_in_group("asteroid")
			var is_enemy = obj.is_in_group("enemy")
			
			if is_enemy and scanner_complexity < 2:
				continue
			
			if not is_station_or_planet and not is_asteroid and not is_enemy:
				continue
			
			var radar_offset = offset * world_to_radar_scale
			
			if radar_offset.length() > radar_radius:
				radar_offset = radar_offset.normalized() * radar_radius
			
			var dot_pos = radar_center + radar_offset
			
			var dot = ColorRect.new()
			dot.position = dot_pos - Vector2(2, 2)
			dot.size = Vector2(4, 4)
			
			if is_station_or_planet:
				dot.color = Color(0, 1, 1, 1)
			elif is_asteroid:
				dot.color = Color(0, 1, 0, 1)
			elif is_enemy:
				dot.color = Color(1, 0, 0, 1)
			
			radar_dots.add_child(dot)
	
	var player_dot = ColorRect.new()
	player_dot.position = radar_center - Vector2(3, 3)
	player_dot.size = Vector2(6, 6)
	player_dot.color = Color(1, 1, 0, 1)
	radar_dots.add_child(player_dot)
