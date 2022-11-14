extends RigidBody2D

const size = 5
const aster_size = 5

var grid = []
var tris = []


enum {UP=0, RIGHT=1, DOWN=2, LEFT=3}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Triangle.hide()
	$Triangle.disabled = true
	init_grid()

func _integrate_forces(state):
	pass

func _draw():
	for t in tris:
		t.queue_free()
	tris = []
	draw_asteroid()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		init_grid()
		update()
		draw_asteroid()

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
	for i in aster_size:
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
		
		if len(possible_dirs) == 0:
			print("grid filled early")
			break
		
		var dir = possible_dirs[randi() % len(possible_dirs)]
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
		mass_sum += 1
		
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

#	self.transform.origin = (center_of_mass_sum / count)
	draw_circle(self.transform.origin, 5.0, Color("#ff00cc"))
	for tri in tris:
		tri.disabled = false
	
func draw_triangle_at_centroid(y,x):
	var flip = (y % 2 == 0 and x % 2 == 1) || (y % 2 == 1 and x % 2 == 0)
	var pX = x * 25
	var pY = y * 25 * sqrt(3)
	var tri = $Triangle.duplicate()
	if flip:
		tri.scale.y = -1
		pY += 25 * sqrt(3)
#	tri.transform.origin = Vector2(pX, pY)
	tri.show()
	add_child(tri)
	draw_circle(tri.transform.origin, 5.0, Color("#00ff00"))
	tris.append(tri)
	
	var ret
	if flip:
		ret = Vector2(pX, pY - 25 * sqrt(3) + ((25 * sqrt(3)) / 2) - 5)
	else: 
		ret = Vector2(pX, pY + (25 * sqrt(3)) / 2 + 5)
#	draw_circle(ret, 5.0, Color("#ff0000"))
	return ret
