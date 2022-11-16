extends Area2D

export var speed = 400
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var increment = 90
	var velocity = Vector2.ZERO # The player's movement vector.
	
	# keyboard inputs
	if Input.is_action_pressed("ui_right"):
		velocity.x += increment
	if Input.is_action_pressed("ui_left"):
		velocity.x -= increment
	if Input.is_action_pressed("ui_down"):
		velocity.y += increment
	if Input.is_action_pressed("ui_up"):
		velocity.y -= increment
	
	# joystick inputs, not perfect will need to look at again
	if Input.is_action_pressed('joy_left') or Input.is_action_pressed('joy_right'):
		velocity.x += Input.get_axis("joy_left", "joy_right") * increment
	if Input.is_action_pressed('joy_up') or Input.is_action_pressed('joy_down'):
		velocity.y += Input.get_axis("joy_up", "joy_down") * increment
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
