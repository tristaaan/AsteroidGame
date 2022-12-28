extends Object

class_name Util

static func distance(a,b):
	return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))

static func break_explosion_velocity(c_pos, explode_origin):
	return (c_pos - explode_origin) * distance(c_pos, explode_origin) / 100
