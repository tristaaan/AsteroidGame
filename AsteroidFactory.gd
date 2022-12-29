extends Node2D

export(PackedScene) var asteroid_scene = preload("res://Asteroid.tscn")

const x_speed_bounds = 10
const y_speed_bound_min = 50
const y_speed_bound_max = 100

const rot_bounds = 0.75

var rng = RandomNumberGenerator.new()

func spawn(spawn_global_position, velocity = null, rot_velocity = null):
	var instance = asteroid_scene.instance()
	instance.init_grid()

	# set velocity vector
	if velocity == null:
		instance.start_speed = Vector2(
			rng.randf_range(-x_speed_bounds, x_speed_bounds),
			rng.randf_range(y_speed_bound_min, y_speed_bound_max)
		)
	else:
		instance.start_speed = velocity
	# set rotation speed
	if rot_velocity == null:
		instance.start_rot = rng.randf_range(-rot_bounds, rot_bounds)
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

		trigger_explosion(instance, c_pos, explode_origin)

func trigger_explosion(instance, c_pos, explode_origin):
	instance.explosion = true
	instance.explosion_origin = explode_origin
	# the magnitude of the explosion vector should be proportional to the distance to origin?
	instance.explosion_velocity = Util.break_explosion_velocity(
		c_pos,
		explode_origin,
		instance.rotation,
		instance.global_transform.origin
	)

func get_asteroid_count():
	var count = 0
	var children = self.get_children()
	for c in children:
		if c is Asteroid:
			count += 1

	return count
