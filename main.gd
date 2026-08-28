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

var asteroids: Array = []
var pirate = null
var starbase = null

@onready var hud = $HUD
@onready var playfield: Node2D = $Playfield
@onready var audio: Node = $AudioManager

var dustbelt_music: AudioStream
var razor_music: AudioStream
var starbase_music: AudioStream

func _ready():
	var CargoGridClass = load("res://cargo_grid.gd")
	cargo_grid = CargoGridClass.new()
	cargo_grid.initialize(cargo_capacity)
	
	dustbelt_music = load("res://audio/music/dustbelt_loop.wav")
	razor_music = load("res://audio/music/razor_loop.wav")
	starbase_music = load("res://audio/music/starbase_loop.wav")
	
	_start_dust_belt()

func _process(_delta):
	if mode == Mode.DUST_BELT:
		_check_starbase_proximity()
	elif mode == Mode.RAZOR_REACH:
		_check_pirate_state()
	
	hud.update_display(hull, max_hull, fuel, max_fuel, credits, cargo_grid.get_filled_slots())

func _start_dust_belt():
	mode = Mode.DUST_BELT
	_clear_playfield()
	
	if audio:
		audio.play_music(dustbelt_music)
	
	player_ship = preload("res://ship.tscn").instantiate()
	player_ship.position = Vector2(640, 360)
	player_ship.main_ref = self
	playfield.add_child(player_ship)
	
	starbase = preload("res://starbase.tscn").instantiate()
	starbase.position = Vector2(640, 180)
	playfield.add_child(starbase)
	
	for i in range(15):
		var asteroid = preload("res://asteroid.tscn").instantiate()
		var angle = randf() * TAU
		var distance = randf_range(200, 500)
		asteroid.position = Vector2(640, 360) + Vector2(cos(angle), sin(angle)) * distance
		asteroid.rarity = _random_rarity()
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
	player_ship.position = Vector2(640, 360)
	player_ship.main_ref = self
	playfield.add_child(player_ship)
	
	pirate = preload("res://pirate.tscn").instantiate()
	pirate.position = Vector2(640, 200)
	pirate.main_ref = self
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
		var distance = player_ship.position.distance_to(Vector2(640, 360))
		if distance > 800:
			_escape_razor_reach()

func _victory_razor_reach():
	await get_tree().create_timer(1.0).timeout
	_start_dust_belt()

func _escape_razor_reach():
	_start_dust_belt()

func try_mine():
	if mode != Mode.DUST_BELT or not player_ship:
		return
	
	for asteroid in asteroids:
		if not is_instance_valid(asteroid):
			continue
		var distance = player_ship.position.distance_to(asteroid.position)
		if distance < mining_range:
			if audio:
				audio.play_sfx("mine")
			var mined = asteroid.mine(mining_power)
			if mined > 0:
				cargo_grid.add_ore(asteroid.rarity, mined)
				if audio:
					audio.play_sfx("ore_pickup")
			if asteroid.ore_remaining <= 0:
				if audio:
					audio.play_sfx("asteroid_break")
				asteroids.erase(asteroid)
			break

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
