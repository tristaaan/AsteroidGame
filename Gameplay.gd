extends Node2D

const count = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_asteroid_field()

func setup_asteroid_field():
	var screen_size = self.get_viewport().get_visible_rect().size
	
	spawn_asteroid_at(100, 500, Vector2(30.0, 0))
	spawn_asteroid_at(400, 500, Vector2(-30.0, 0))

func spawn_asteroid_at(x, y, velocity = null):
	$AsteroidFactory.spawn(Vector2(x,y), velocity)
