extends Node2D

export(PackedScene) var asteroid_scene = preload("res://Asteroid.tscn")

const speed_bounds = 10
var rng = RandomNumberGenerator.new()

func spawn(spawn_global_position, velocity = null):
	var instance = asteroid_scene.instance()
	if velocity == null:
		instance.start_speed = Vector2(
			rng.randf_range(-speed_bounds, speed_bounds),
			rng.randf_range(-speed_bounds, speed_bounds)
		)
	else:
		instance.start_speed = velocity
	instance.start_rot = rng.randf_range(-2, 2)
	instance.start_pos = spawn_global_position
	instance.global_position = spawn_global_position
	instance.transform.origin = spawn_global_position
	add_child(instance)
	instance.reset = true
