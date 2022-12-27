extends Node2D

export(PackedScene) var asteroid_scene = preload("res://Asteroid.tscn")

const speed_bounds = 10
var rng = RandomNumberGenerator.new()

func spawn(spawn_global_position, velocity = null, rot_velocity = null):
	var instance = asteroid_scene.instance()
	instance.init_grid()
	
	# set velocity vector
	if velocity == null:
		instance.start_speed = Vector2(
			rng.randf_range(-speed_bounds, speed_bounds),
			rng.randf_range(-speed_bounds, speed_bounds)
		)
	else:
		instance.start_speed = velocity
	# set rotation speed
	if rot_velocity == null:
		instance.start_rot = rng.randf_range(-2, 2)
	else:
		instance.start_rot = rot_velocity
		
	instance.start_pos = spawn_global_position
	instance.global_position = spawn_global_position
	instance.transform.origin = spawn_global_position
	instance.connect("asteroid_break", self, "asteroid_did_break")
	add_child(instance)
	instance.reset = true
	
func asteroid_did_break(components, component_positions, rot, velocity, angular_velocity, explode_origin):
	for i in components.size(): 
		var c = components[i]
		var c_pos = component_positions[i]
		var instance = asteroid_scene.instance()
		instance.init(c)
		instance.start_pos = c_pos
		instance.start_angle = rot
		instance.start_speed = velocity
		# this is a weird one to calculate
		instance.start_rot = angular_velocity / 2
		instance.connect("asteroid_break", self, "asteroid_did_break")
		add_child(instance)
		instance.reset = true
		
		instance.explosion = true
		instance.explosion_origin = explode_origin
		instance.explosion_velocity = -(c_pos - explode_origin) / 5



