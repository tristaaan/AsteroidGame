extends CollisionPolygon2D

signal hit(at_array_coordinate)

var array_coordinate

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var inside = Geometry.is_point_in_polygon(
			to_local(event.position), 
			self.polygon
		)
		if inside:
			emit_signal("hit", array_coordinate)
		
