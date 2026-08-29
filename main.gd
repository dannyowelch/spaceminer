extends Node2D

enum Mode { DUST_BELT, DOCK, RAZOR_REACH }

var mode: Mode = Mode.DUST_BELT
var player_ship = null
var cargo_grid = null
var credits: int = 0
var hull: int = 10
var max_hull: int = 10
var fuel: int = 100
var max_fuel: int = 100
var mining_range: float = 120.0
var mining_power: int = 3
var cargo_capacity: int = 12
var has_weapon: bool = false
var weapon_damage: int = 2
var scanner_complexity: int = 1

var asteroids: Array = []
var pirate = null
var starbase = null

const WORLD_WIDTH: float = 5280.0
const WORLD_HEIGHT: float = 4000.0
const SCANNER_RANGE: float = 900.0

@onready var hud = $HUD_1080
@onready var playfield: Node2D = $PlayfieldClip/SubViewport/Playfield
@onready var camera: Camera2D = $PlayfieldClip/SubViewport/Camera2D
@onready var audio: Node = $AudioManager
@onready var starfield: Sprite2D = $Starfield
var planet: Sprite2D

var dustbelt_music: AudioStream
var razor_music: AudioStream
var starbase_music: AudioStream

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var starfield_img = Image.load_from_file("res://sprites/starfield.png")
	if starfield_img == null:
		push_error("Failed to load starfield.png")
	else:
		var starfield_texture = ImageTexture.create_from_image(starfield_img)
		starfield.texture = starfield_texture
		starfield.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var CargoGridClass = load("res://cargo_grid.gd")
	cargo_grid = CargoGridClass.new()
	cargo_grid.initialize(cargo_capacity)
	
	dustbelt_music = load("res://audio/music/dustbelt_loop.wav")
	razor_music = load("res://audio/music/razor_loop.wav")
	starbase_music = load("res://audio/music/starbase_loop.wav")
	
	_start_dust_belt()

func _process(_delta):
	if player_ship and camera:
		camera.position = player_ship.position
	
	if mode == Mode.DUST_BELT:
		_check_starbase_proximity()
	elif mode == Mode.RAZOR_REACH:
		_check_pirate_state()
	
	var sector_name = ""
	match mode:
		Mode.DUST_BELT:
			sector_name = "DUST BELT"
		Mode.DOCK:
			sector_name = "STARBASE"
		Mode.RAZOR_REACH:
			sector_name = "RAZOR REACH"
	
	if hud:
		hud.main_ref = self
		hud.update_display(hull, max_hull, fuel, max_fuel, credits, sector_name)
		hud.update_cargo(cargo_grid)
		
		if player_ship and (mode == Mode.DUST_BELT or mode == Mode.RAZOR_REACH):
			var world_objects = []
			if starbase:
				world_objects.append(starbase)
			if planet:
				world_objects.append(planet)
			for asteroid in asteroids:
				if is_instance_valid(asteroid):
					world_objects.append(asteroid)
			if pirate:
				world_objects.append(pirate)
			
			hud.update_radar(player_ship.position, world_objects, SCANNER_RANGE, scanner_complexity)

func _start_dust_belt():
	mode = Mode.DUST_BELT
	_clear_playfield()
	
	if audio:
		audio.play_music(dustbelt_music)
	
	planet = Sprite2D.new()
	planet.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var planet_img = Image.load_from_file("res://sprites/planet.png")
	if planet_img == null:
		push_error("Failed to load planet.png")
	else:
		planet.texture = ImageTexture.create_from_image(planet_img)
	
	planet.position = Vector2(500, 2000)
	planet.z_index = -5
	planet.add_to_group("planet")
	playfield.add_child(planet)
	
	player_ship = preload("res://ship.tscn").instantiate()
	player_ship.position = Vector2(WORLD_WIDTH / 2, WORLD_HEIGHT / 2)
	player_ship.main_ref = self
	playfield.add_child(player_ship)
	
	starbase = preload("res://starbase.tscn").instantiate()
	starbase.position = Vector2(WORLD_WIDTH / 2, 1200)
	starbase.add_to_group("station")
	playfield.add_child(starbase)
	
	var num_clumps = randi_range(4, 6)
	var asteroids_per_clump = 8
	
	for clump_idx in range(num_clumps):
		var clump_center = Vector2(
			randf_range(800, WORLD_WIDTH - 800),
			randf_range(800, WORLD_HEIGHT - 800)
		)
		
		var dist_to_spawn = clump_center.distance_to(player_ship.position)
		if dist_to_spawn < 600:
			continue
		
		for i in range(asteroids_per_clump):
			var asteroid = preload("res://asteroid.tscn").instantiate()
			var offset = Vector2(
				randf_range(-300, 300),
				randf_range(-300, 300)
			)
			asteroid.position = clump_center + offset
			asteroid.rarity = _random_rarity()
			asteroid.add_to_group("asteroid")
			playfield.add_child(asteroid)
			asteroids.append(asteroid)

func _start_dock():
	mode = Mode.DOCK
	_clear_playfield()
	
	if audio:
		audio.play_music(starbase_music)
		audio.play_sfx("dock")
	
	var dock_ui = preload("res://dock_ui.tscn").instantiate()
	dock_ui.main_ref = self
	playfield.add_child(dock_ui)

func _start_razor_reach():
	mode = Mode.RAZOR_REACH
	_clear_playfield()
	
	if audio:
		audio.play_music(razor_music)
		audio.play_sfx("pirate_sting")
	
	player_ship = preload("res://ship.tscn").instantiate()
	player_ship.position = Vector2(WORLD_WIDTH / 2, WORLD_HEIGHT / 2)
	player_ship.main_ref = self
	playfield.add_child(player_ship)
	
	pirate = preload("res://pirate.tscn").instantiate()
	pirate.position = Vector2(WORLD_WIDTH / 2, 1200)
	pirate.main_ref = self
	pirate.add_to_group("enemy")
	playfield.add_child(pirate)

func _clear_playfield():
	for child in playfield.get_children():
		child.queue_free()
	asteroids.clear()
	pirate = null
	starbase = null

func _check_starbase_proximity():
	if player_ship and starbase:
		var distance = player_ship.position.distance_to(starbase.position)
		if distance < 80 and Input.is_action_just_pressed("dock"):
			_start_dock()

func _check_pirate_state():
	if pirate and pirate.hull <= 0:
		_victory_razor_reach()
	
	if player_ship:
		var distance = player_ship.position.distance_to(Vector2(480, 360))
		if distance > 600:
			_escape_razor_reach()

func _victory_razor_reach():
	await get_tree().create_timer(1.0).timeout
	_start_dust_belt()

func _escape_razor_reach():
	_start_dust_belt()

func try_mine():
	if mode != Mode.DUST_BELT or not player_ship:
		return
	
	var scoop_pos = player_ship.get_scoop_position()
	var facing = player_ship.get_facing()
	var beam_end = scoop_pos + facing * mining_range
	
	var closest_asteroid = null
	var closest_distance = INF
	
	for asteroid in asteroids:
		if not is_instance_valid(asteroid):
			continue
		
		var hit = _line_intersects_circle(scoop_pos, beam_end, asteroid.position, 40.0)
		if hit:
			var distance = scoop_pos.distance_to(asteroid.position)
			if distance < closest_distance:
				closest_distance = distance
				closest_asteroid = asteroid
	
	if closest_asteroid:
		if audio:
			audio.play_sfx("mine")
		var mined = closest_asteroid.mine(mining_power)
		if mined > 0:
			cargo_grid.add_ore(closest_asteroid.rarity, mined)
			if audio:
				audio.play_sfx("ore_pickup")
		if closest_asteroid.ore_remaining <= 0:
			if audio:
				audio.play_sfx("asteroid_break")
			asteroids.erase(closest_asteroid)

func _line_intersects_circle(line_start: Vector2, line_end: Vector2, circle_pos: Vector2, circle_radius: float) -> bool:
	var d = line_end - line_start
	var f = line_start - circle_pos
	
	var a = d.dot(d)
	var b = 2 * f.dot(d)
	var c = f.dot(f) - circle_radius * circle_radius
	
	var discriminant = b * b - 4 * a * c
	if discriminant < 0:
		return false
	
	var t1 = (-b - sqrt(discriminant)) / (2 * a)
	var t2 = (-b + sqrt(discriminant)) / (2 * a)
	
	return (t1 >= 0 and t1 <= 1) or (t2 >= 0 and t2 <= 1)

func sell_all_ore() -> int:
	var total = 0
	var ore_values = {"common": 10, "uncommon": 25, "rare": 50}
	for slot in cargo_grid.slots:
		if slot.ore_type != "":
			total += ore_values.get(slot.ore_type, 0) * slot.amount
	cargo_grid.clear()
	credits += total
	return total

func buy_upgrade(upgrade_type: String, cost: int) -> bool:
	if credits < cost:
		return false
	
	credits -= cost
	
	match upgrade_type:
		"mining_beam":
			mining_power += 2
			mining_range += 20
		"cargo_hold":
			cargo_capacity += 4
			cargo_grid.expand(cargo_capacity)
		"weapon":
			has_weapon = true
	
	return true

func damage_hull(amount: int):
	hull -= amount
	if audio:
		audio.play_sfx("hull_hit")
	if hull <= 0:
		_game_over()

func _game_over():
	hull = max_hull
	credits = 0
	cargo_grid.clear()
	_start_dust_belt()

func _random_rarity() -> String:
	var roll = randf()
	if roll < 0.6:
		return "common"
	elif roll < 0.9:
		return "uncommon"
	else:
		return "rare"
