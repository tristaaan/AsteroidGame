extends Area2D

export(int) var bulletSpeed = -180

func _ready():
	set_as_toplevel(true)
	
func _process(delta):
	if is_outside_view_bounds():
		queue_free()
	move_local_y(delta * bulletSpeed)
	
#outside bounds calculation
func is_outside_view_bounds():
	return position.x>OS.get_screen_size().x or position.x<0.0\
		or position.y>OS.get_screen_size().y or position.y<0.0

func _on_Bullet_body_entered(body):
	print(body)
	if body.get_collision_layer_bit(0):
		body.hit_by_bullet()
	queue_free()
