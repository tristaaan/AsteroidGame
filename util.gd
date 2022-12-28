extends Object

class_name Util

static func distance(a,b):
	return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))

static func break_explosion_velocity(c_pos, explode_origin, aster_rotation, aster_origin):
	explode_origin = rotate_around(explode_origin, aster_rotation, aster_origin)
	return c_pos-explode_origin # * (distance(c_pos, explode_origin) / 10)

static func rotate_around(pt, theta, center):
	var cx = center.x;
	var cy = center.y;

	var nx = pt.x
	var ny = pt.y
	var cos_t = cos(theta)
	var sin_t = sin(theta)
	# move to origin
	var tx = nx - cx
	var ty = ny - cy

	# rotate
	nx = tx * cos_t - ty * sin_t
	ny = ty * cos_t + tx * sin_t

	# restore old center
	return Vector2(nx + cx, ny + cy)
