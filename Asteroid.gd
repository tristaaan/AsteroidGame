extends RigidBody2D

const size = 5
const aster_size = 5

var grid = []
var tris = []
var coord_map = {}
var graph = {}

var reset = false
var start_angle = 0
var start_pos = Vector2(0, 0)
var start_speed = Vector2(0, 0)
var start_rot = 0

var DEBUG = true

enum {UP=0, RIGHT=1, DOWN=2, LEFT=3}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Triangle.hide()
	$Triangle.disabled = true
	$TriangleFlip.hide()
	$TriangleFlip.disabled = true
	init_grid()

func _integrate_forces(state):
	if reset:
		state.transform = Transform2D(start_angle, start_pos)
		state.linear_velocity = start_speed
		state.angular_velocity = start_rot
		reset = false

func _draw():
	for t in tris:
		t.queue_free()
	tris = []
	coord_map = {}
	draw_asteroid()
	
func _unhandled_input(event):
	pass
#	if event.is_action_pressed("ui_accept"):
#		init_grid()
#		update()
#		draw_asteroid()

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
	
func init_grid():
	grid = []
	# init the grid with null
	for i in size:
		var row = []
		for j in size:
			row.append(false)
		grid.append(row)
	
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
		var prev_coord = Vector2(posY, posX)
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
		
	self.mass = mass_sum
#	for row in grid:
#		print(row)

func draw_asteroid():
	var center_of_mass_sum = Vector2(0,0)
	var count = 0
	for i in size:
		for j in size:
			if grid[i][j]:
				var com = draw_triangle_at_centroid(i,j)
				center_of_mass_sum += com
				count += 1
		#print(grid[i])
		
	var center_of_mass = (center_of_mass_sum / count)
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
		pY += 25 * sqrt(3)
	else:
		tri = $Triangle.duplicate()
	tri.array_coordinate = Vector2(x,y)
	tri.connect("hit", self, "hit_registered")
	tri.position = Vector2(pX, pY)
	tris.append(tri)
	coord_map[Vector2(x,y)] = tri
	
	var ret
	if flip:
		ret = Vector2(pX, pY - 25 * sqrt(3) + ((25 * sqrt(3)) / 2) - 5)
	else: 
		ret = Vector2(pX, pY + (25 * sqrt(3)) / 2 + 5)
	return ret

func vec_compare(vec_a, vec_b):
	return vec_a.x == vec_b.x and vec_a.y == vec_b.y

func hit_registered(array_coordinate):
	var tri:Triangle = coord_map[array_coordinate]
	var norm_coord = Vector2(array_coordinate.y, array_coordinate.x)
	tri.set_strength(tri.get_strength() - 2)
	print(array_coordinate, tri.get_strength())
	if tri.get_strength() <= 0:
		# destroy tri
		remove_child(tri)
		grid[array_coordinate.y][array_coordinate.x] = false
		
		# update graph
		for coord in graph[norm_coord]:
			var index = graph[coord].bsearch_custom(norm_coord, self, "vec_compare", false)
			graph[coord].remove(index)
		graph[norm_coord] = null
		
#		var tmp_start_pos = self.global_position
#		self.start_pos = tmp_start_pos
#		self.reset = true
#		update()

		# delete entire asteroid if necessary 
		if all_destroyed():
			self.queue_free()
			if DEBUG:
				print('asteroid all destroyed')
		
func all_destroyed():
	for i in size:
		for j in size:
			if grid[i][j]:
				return false
	return true
