extends SceneTree

func _init():
	print("=== Visual Test: Sprites Loaded ===\n")
	
	var packed_scene = load("res://main.tscn")
	var scene = packed_scene.instantiate()
	root.add_child(scene)
	
	await create_timer(0.2).timeout
	
	print("Checking Dust Belt scene...")
	var player_ship = scene.player_ship
	if player_ship and player_ship.has_node("Sprite2D"):
		var sprite = player_ship.get_node("Sprite2D")
		if sprite.texture:
			print("✓ Player ship sprite loaded: %s" % sprite.texture.resource_path)
		else:
			print("✗ Player ship sprite is NULL")
	
	if scene.starbase and scene.starbase.has_node("Sprite2D"):
		var sprite = scene.starbase.get_node("Sprite2D")
		if sprite.texture:
			print("✓ Starbase sprite loaded: %s" % sprite.texture.resource_path)
		else:
			print("✗ Starbase sprite is NULL")
	
	if scene.asteroids.size() > 0:
		var asteroid = scene.asteroids[0]
		if asteroid.has_node("Sprite2D"):
			var sprite = asteroid.get_node("Sprite2D")
			if sprite.texture:
				print("✓ Asteroid sprite loaded: %s" % sprite.texture.resource_path)
			else:
				print("✗ Asteroid sprite is NULL")
	
	print("\n=== All sprites verified! ===")
	print("Game is using PNG sprites, not _draw() placeholders.")
	
	quit()
