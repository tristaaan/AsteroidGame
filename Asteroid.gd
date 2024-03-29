extends RigidBody2D

const size = 5
const aster_size = 8
const base_mass = 5

signal asteroid_break(components, component_positions, rot, velocity, angular_velocity, explode_origin)
export(PackedScene) var Explosion = preload("res://Explosion.tscn")

var grid = []
var tris = []
var coord_map = {}
var graph = {}
var strength_map = {}

# variables and flags to setup
var reset = false
var start_angle = 0
var start_pos = Vector2(0, 0)
var start_speed = Vector2(0, 0)
var start_rot = 0

# particle effects
var explosion = false
var explosion_velocity = null
var explosion_origin = null

var DEBUG = false

enum {UP=0, RIGHT=1, DOWN=2, LEFT=3}

class_name Asteroid

# Called when the node enters the scene tree for the first time.
func _ready():
	$Triangle.hide()
	$Triangle.disabled = true
	$TriangleFlip.hide()
	$TriangleFlip.disabled = true

func _integrate_forces(state):
	if reset:
		state.transform = Transform2D(start_angle, start_pos)
		state.linear_velocity = start_speed
		state.angular_velocity = start_rot
		reset = false

	if explosion:
		self.apply_impulse(explosion_origin, explosion_velocity)
		explosion = false

func _draw():
	for t in tris:
		t.queue_free()
	tris = []
	coord_map = {}
	draw_asteroid()

func init(starter_graph, init_strength_map):
	graph = starter_graph
	strength_map = init_strength_map
	grid = empty_grid()
	for k in graph.keys():
		grid[k.x][k.y] = true
	self.mass = len(graph) * base_mass

func get_possible_directions(posX, posY):
	var possible_dirs = []
	var oddX = posX % 2 == 1
	var oddY = posY % 2 == 1
	# vertical
	if !oddY and oddX || oddY and !oddX:
		# no down
		if posY > 0:
			possible_dirs.append(UP)
	elif oddY and oddX || !oddY and !oddX:
		# no up
		if posY < size - 1:
			possible_dirs.append(DOWN)

	# horizontal
	if posX == 0:
		possible_dirs.append(RIGHT)
	elif posX == size - 1:
		possible_dirs.append(LEFT)
	else:
		possible_dirs.append(LEFT)
		possible_dirs.append(RIGHT)
	return possible_dirs

func empty_grid():
	var ret = []
	for i in size:
		var row = []
		for j in size:
			row.append(false)
		ret.append(row)
	return ret

func init_grid():
	# init the grid with false
	grid = empty_grid()

	# random walk the grid
	var posX = randi() % size
	var posY = randi() % size
	var mass_sum = 1

	grid[posY][posX] = true
	graph[Vector2(posY, posX)] = []
	for i in aster_size:

		var possible_dirs = get_possible_directions(posX, posY)
		if len(possible_dirs) == 0:
			print("grid filled early")
			break

		var dir = possible_dirs[randi() % len(possible_dirs)]
#		var prev_coord = Vector2(posY, posX)
		match dir:
			UP:
				posY -= 1
			RIGHT:
				posX += 1
			DOWN:
				posY += 1
			LEFT:
				posX -= 1
		grid[posY][posX] = true

		var adjacents = []
		possible_dirs = get_possible_directions(posX, posY)
		for pdir in possible_dirs:
			match pdir:
				UP:
					if grid[posY - 1][posX]:
						adjacents.append(Vector2(posY - 1, posX))
				RIGHT:
					if grid[posY][posX + 1]:
						adjacents.append(Vector2(posY, posX + 1))
				DOWN:
					if grid[posY + 1][posX]:
						adjacents.append(Vector2(posY + 1,posX))
				LEFT:
					if grid[posY][posX - 1]:
						adjacents.append(Vector2(posY, posX - 1))

		# add reference to graph
		var cur_coord = Vector2(posY, posX)
		graph[cur_coord] = adjacents
		for adj in adjacents:
			if not graph[adj].has(cur_coord):
				graph[adj].append(cur_coord)
		mass_sum += 1
		if DEBUG:
			print(graph)

	self.mass = mass_sum * base_mass

func draw_asteroid():
	var center_of_mass_sum = Vector2(0,0)

	for t in graph.keys():
		var com = draw_triangle_at_centroid(int(t.x), int(t.y))
		center_of_mass_sum += com

	var center_of_mass = (center_of_mass_sum / len(graph))
	self.transform.origin = center_of_mass
	self.position = Vector2.ZERO
	for tri in tris:
		tri.position -= center_of_mass
		if DEBUG:
			draw_circle(tri.position, 5.0, Color("#00ff00"))
		tri.disabled = false
		tri.show()
		add_child(tri)
	if DEBUG:
		draw_circle(self.transform.origin, 5.0, Color("#ff00cc"))
#	self.transform.origin = Vector2(0,0)

func draw_triangle_at_centroid(y, x):
	var flip = (y % 2 == 0 and x % 2 == 1) || (y % 2 == 1 and x % 2 == 0)
	var pX = x * 25
	var pY = y * 25 * sqrt(3)
	var tri
	if flip:
		tri = $TriangleFlip.duplicate()
		tri.is_flip = true
		pY += 25 * sqrt(3)
	else:
		tri = $Triangle.duplicate()
	var coord_key = Vector2(x,y)

	if strength_map.has(coord_key):
		tri.set_strength(strength_map[coord_key])
	tri.array_coordinate = Vector2(x,y)
	tri.connect("hit", self, "hit_registered")
	tri.position = Vector2(pX, pY)
	tris.append(tri)
	coord_map[coord_key] = tri

	var ret
	if flip:
		ret = Vector2(pX, pY - 25 * sqrt(3) + ((25 * sqrt(3)) / 2) - 5)
	else:
		ret = Vector2(pX, pY + (25 * sqrt(3)) / 2 + 5)
	return ret

func hit_registered(array_coordinate):
	var tri:Triangle = coord_map[array_coordinate]
	var hit_coord = Vector2(array_coordinate.y, array_coordinate.x)
	var is_flip = tri.is_flip

	var global_hit_coord = tri.global_position
	var local_hit_coord = adjust_coord(tri.position, is_flip)

	tri.set_strength(tri.get_strength() - 2)

	if tri.get_strength() <= 0:
		# destroy tri
		remove_child(tri)
		self.mass -= base_mass
		grid[array_coordinate.y][array_coordinate.x] = false

		# remove destroyed node from graph
		for coord in graph[hit_coord]:
			var index = graph[coord].find(hit_coord)
			graph[coord].remove(index)

		match len(graph[hit_coord]):
			2:
				var neighbors = graph[hit_coord]
				graph.erase(hit_coord)
				var components = []
				var neighbor_coords = []

				for n in neighbors:
					components.append(get_component(n))
					neighbor_coords.append(coord_map[yx2xy(n)].position)

				# check if there are 2 new asteroids from this
				if not components[0].has(components[1][0]):
					var	graphs = []
					var component_positions = []
					var component_strengths = []
					for coords in components:
						var component_graph = {}
						var component_strength = {}
						for coord in coords:
							component_graph[coord] = graph[coord]
							component_strength[yx2xy(coord)] = coord_map[yx2xy(coord)].strength
						graphs.append(component_graph)
						component_strengths.append(component_strength)
						component_positions.append(
							calulate_component_global_center(
								component_graph
							)
						)
					emit_signal("asteroid_break",
						graphs,
						component_positions,
						component_strengths,
						rotation,
						self.linear_velocity,
						self.angular_velocity,
						neighbor_coords,
						local_hit_coord
					)
					play_explosion_at(global_hit_coord, is_flip)
					self.queue_free()
			1:
				play_explosion_at(global_hit_coord, is_flip)
				var neighbor_pos = true_coord(coord_map[yx2xy(graph[hit_coord][0])])
				var impulse = Util.break_explosion_velocity(
					neighbor_pos,
					local_hit_coord,
					self.rotation,
					Vector2(0,0)
				)
				self.apply_impulse(
					local_hit_coord,
					impulse
				)
				tri.queue_free()
				graph.erase(hit_coord)
			0:
				# Lone tri was destroyed
				play_explosion_at(global_hit_coord, is_flip)
				self.queue_free()
				if DEBUG:
					print('asteroid all destroyed')
			_:
				print("impossible case, did you click away the tri?")

func play_explosion_at(pos, is_flip):
	var explosion_emitter = Explosion.instance()
	get_parent().add_child(explosion_emitter)
	explosion_emitter.global_position = adjust_coord(pos, is_flip)

func true_coord(tri):
	return adjust_coord(tri.position, tri.is_flip)

func adjust_coord(vec2, is_flip):
	if is_flip:
		return vec2 - magic_offset(is_flip)
	return vec2 + magic_offset(is_flip)

func magic_offset(is_flip):
	# calculate the center offset of a tri
	if is_flip:
		return Vector2(0, 25 * sqrt(3) / 2 - 5).rotated(self.rotation)
	return Vector2(0, 25 * sqrt(3) / 2 + 5).rotated(self.rotation)

func yx2xy(a):
	# flip the coordinates of a vector
	return Vector2(a.y, a.x)

func calulate_component_global_center(component):
	var com = Vector2(0,0)

	for c in component.keys():
		com += coord_map[yx2xy(c)].global_position

	return com / len(component)

func get_component(start):
	var q_front = [start]
	var visited = [start]
	var neighbors = []
	while q_front.size() > 0:
		var front = q_front.pop_front()
		neighbors = graph[front]
		for n in neighbors:
			if not visited.has(n):
				q_front.append(n)
		visited.append(front)

	return visited

# in the future this could take damange depending on weapon :)
func hit_by_bullet(body_index):
	var tri:Triangle = get_child(body_index)
	hit_registered(tri.array_coordinate)
