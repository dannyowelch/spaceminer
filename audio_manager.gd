extends Node

var music_bus_idx: int
var current_music: AudioStreamPlayer
var next_music: AudioStreamPlayer
var crossfade_time: float = 0.8
var crossfade_timer: float = 0.0
var is_crossfading: bool = false
var duck_amount: float = -3.0
var original_music_volume: float = 0.0
var is_ducked: bool = false

@onready var music_player_1: AudioStreamPlayer = $MusicPlayer1
@onready var music_player_2: AudioStreamPlayer = $MusicPlayer2
@onready var sfx_thrust: AudioStreamPlayer = $SFX/Thrust
@onready var sfx_mine: AudioStreamPlayer = $SFX/Mine
@onready var sfx_fire: AudioStreamPlayer = $SFX/Fire
@onready var sfx_ore_pickup: AudioStreamPlayer = $SFX/OrePickup
@onready var sfx_hull_hit: AudioStreamPlayer = $SFX/HullHit
@onready var sfx_asteroid_break: AudioStreamPlayer = $SFX/AsteroidBreak
@onready var sfx_explosion: AudioStreamPlayer = $SFX/Explosion
@onready var sfx_pirate_sting: AudioStreamPlayer = $SFX/PirateString
@onready var sfx_dock: AudioStreamPlayer = $SFX/Dock
@onready var sfx_sell: AudioStreamPlayer = $SFX/Sell
@onready var sfx_ui_ok: AudioStreamPlayer = $SFX/UiOk
@onready var sfx_ui_deny: AudioStreamPlayer = $SFX/UiDeny

func _ready():
	music_bus_idx = AudioServer.get_bus_index("Music")
	current_music = music_player_1
	original_music_volume = 0.0

func _process(delta):
	if is_crossfading:
		crossfade_timer += delta
		var progress = minf(crossfade_timer / crossfade_time, 1.0)
		
		if current_music:
			current_music.volume_db = lerp(0.0, -80.0, progress)
		if next_music:
			next_music.volume_db = lerp(-80.0, 0.0, progress)
		
		if progress >= 1.0:
			if current_music:
				current_music.stop()
			current_music = next_music
			next_music = null
			is_crossfading = false
			crossfade_timer = 0.0

func play_music(stream: AudioStream):
	var target_player = music_player_2 if current_music == music_player_1 else music_player_1
	target_player.stream = stream
	target_player.volume_db = -80.0
	target_player.play()
	
	next_music = target_player
	is_crossfading = true
	crossfade_timer = 0.0

func duck_music():
	if not is_ducked:
		is_ducked = true
		var tween = create_tween()
		tween.tween_property(AudioServer.get_bus_effect(music_bus_idx, -1) if false else self, 
			"volume", duck_amount, 0.2)
		AudioServer.set_bus_volume_db(music_bus_idx, duck_amount)

func unduck_music():
	if is_ducked:
		is_ducked = false
		AudioServer.set_bus_volume_db(music_bus_idx, original_music_volume)

func play_sfx(sfx_name: String):
	match sfx_name:
		"thrust":
			if not sfx_thrust.playing:
				sfx_thrust.play()
		"mine":
			sfx_mine.play()
		"fire":
			sfx_fire.play()
		"ore_pickup":
			sfx_ore_pickup.play()
		"hull_hit":
			sfx_hull_hit.play()
		"asteroid_break":
			sfx_asteroid_break.play()
		"explosion":
			sfx_explosion.play()
		"pirate_sting":
			sfx_pirate_sting.play()
			duck_music()
			await get_tree().create_timer(1.5).timeout
			unduck_music()
		"dock":
			sfx_dock.play()
		"sell":
			sfx_sell.play()
		"ui_ok":
			sfx_ui_ok.play()
		"ui_deny":
			sfx_ui_deny.play()

func stop_thrust():
	sfx_thrust.stop()
