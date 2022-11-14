extends Node2D

export(PackedScene) var asteroid_scene = preload("res://Asteroid.tscn")

const speed_bounds = 10
var rng = RandomNumberGenerator.new()

func spawn(spawn_global_position, velocity = null):
	var instance = asteroid_scene.instance()
	if velocity == null:
		instance.apply_central_impulse(
			rng.randf_range(-speed_bounds, speed_bounds),
			rng.randf_range(-speed_bounds, speed_bounds)
		)
	else:
		instance.apply_central_impulse(velocity)
	instance.global_position = spawn_global_position
	add_child(instance)
