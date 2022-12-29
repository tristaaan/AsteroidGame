extends Node2D

const max_count = 30
const DEBUG = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if DEBUG:
		setup_asteroid_field()
	else:
		setup_asteroid_field()

func setup_debug_asteroid_field():
	spawn_asteroid_at(100, 250, Vector2(0, 0), 0.5)
	spawn_asteroid_at(700, 150, Vector2(0, -0), 0)
	spawn_asteroid_at(400, 250, Vector2(-0, 0), 0)

func setup_asteroid_field():
	while $AsteroidFactory.get_asteroid_count() < max_count:
		spawn_asteroid_random()

func spawn_asteroid_random():
	var max_left = $LeftMaxSpawn.position
	var max_right = $RightMaxSpawn.position
	# random point between left and right
	var x = rand_range(max_left.x, max_right.x)
	# random point between top of viewport and left extent
	var y = rand_range(max_left.y, -100)
	spawn_asteroid_at(x,y)

func spawn_asteroid_at(x, y, velocity = null, rot_velocity=null):
	print("spawned at", x, y)
	$AsteroidFactory.spawn(Vector2(x,y), velocity, rot_velocity)

func _on_ValidAsteroidArea_body_exited(body):
	if not is_instance_valid(body):
		return

	if body is Asteroid:
		body.queue_free()
		if $AsteroidFactory.get_asteroid_count() < max_count:
			spawn_asteroid_random()

	print(OS.get_unix_time(), " a:", $AsteroidFactory.get_asteroid_count())
