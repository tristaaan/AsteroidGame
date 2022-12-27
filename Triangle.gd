extends CollisionPolygon2D

signal hit(at_array_coordinate)

var array_coordinate
var initial_str:float = 4.0 setget set_initial_strength
var strength:float = initial_str setget set_strength, get_strength
var is_flip:bool = false

class_name Triangle

func _ready():
	strength = initial_str

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var inside = Geometry.is_point_in_polygon(
			to_local(event.position), 
			self.polygon
		)
		if inside:
			emit_signal("hit", array_coordinate)
		
func set_initial_strength(newVal):
	initial_str = newVal
	strength = initial_str
	modulate = Color(1.0, 1.0, 1.0)
		
func set_strength(newVal):
	strength = newVal
	modulate = Color(1.0, strength / initial_str, strength / initial_str)
	
func get_strength():
	return strength
