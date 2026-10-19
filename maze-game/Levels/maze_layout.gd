extends TileMapLayer


var GRID_SIZE = (2**(LevelManager.current_level))-1
const TURN_BIAS = 0

@export var goal_scene: PackedScene

@export_group("Power-Ups")
@export var powerup_scene: PackedScene
@export var powerup_count: int = ceil(LevelManager.current_level/2) + 2
@export var powerup_ids: Array[int] = [0,1,2,3,4,5]

@export_group("Enemy Rats")
@export var rat_scene: PackedScene
@export var rat_count: int = ceil(LevelManager.current_level/2)
@export var move_num: int = 2

@export_group("Enemy Bats")
@export var bat_scene: PackedScene
@export var bat_count: int = ceil(LevelManager.current_level/2)

var tile_values: Array[Array] = []
var visited: Dictionary = {}
var occupied: Dictionary = {}

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -2),
	Vector2i(0, 2),
	Vector2i(-2, 0),
	Vector2i(2, 0)
]

const ENEMY_DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(1, 0)
]

var traversal_directions: Array[Vector2i] = []
var visited_nodes: Array[Vector2i] = []

func _ready():
	if GRID_SIZE < 7:
		GRID_SIZE = 7
	randomize()
	generate_tiles()
	depth_first_search(Vector2i(0, 0))
	update_tiles()
	add_walls()
	
	var distances = find_distances(Vector2i(0, 0))
	var goal_cell = find_farthest_node(distances)
	
	place_goal(goal_cell)
	
	spawn_powerups()
	spawn_normal_enemies()
	spawn_flying_enemies()

func generate_tiles():
	tile_values.clear()

	for x in range(GRID_SIZE):
		var column: Array[int] = []
		
		for y in range(GRID_SIZE):
			var value = int(x % 2 != 0 or y % 2 != 0)
			#if randi_range(0, 9) == 0:
				#value = 0
			column.append(value)
		tile_values.append(column)

func update_tiles():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var cell = Vector2i(x, y)
			var value = tile_values[x][y]
			var source_id = 6 if value == 0 else 1
			set_cell(cell, source_id, Vector2i.ZERO)
			
func add_walls():
	for y in range(GRID_SIZE+2):
		var cell = Vector2i(-1, y-1)
		set_cell(cell, 1, Vector2i.ZERO)
		cell = Vector2i(GRID_SIZE, y-1)
		set_cell(cell, 1, Vector2i.ZERO)
	for x in range(GRID_SIZE):
		var cell = Vector2i(x, -1)
		set_cell(cell, 1, Vector2i.ZERO)
		cell = Vector2i(x, GRID_SIZE)
		set_cell(cell, 1, Vector2i.ZERO)
	

func depth_first_search(current: Vector2i, previous_direction: Vector2i = Vector2i.ZERO):
	
	visited[current] = true
	visited_nodes.append(current)

	var directions = DIRECTIONS.duplicate()
	directions.shuffle()
	if previous_direction != Vector2i.ZERO and randf() < TURN_BIAS:
		var turn_directions: Array[Vector2i] = []
		var straight_directions: Array[Vector2i] = []
		
		for direction in directions:
			if direction == previous_direction:
				straight_directions.append(direction)
			else:
				turn_directions.append(direction)
		
		directions.clear()
		directions.append_array(turn_directions)
		directions.append_array(straight_directions)
	
	for direction in directions:
		var next = current + direction
		if next.x < 0 or next.x >= GRID_SIZE:
			continue
		if next.y < 0 or next.y >= GRID_SIZE:
			continue
		if tile_values[next.x][next.y] != 0:
			continue
		if visited.has(next):
			continue
			
		var between = current + direction / 2
		tile_values[between.x][between.y] = 0
		traversal_directions.append(direction)
		depth_first_search(next, direction)
		
		traversal_directions.append(-direction)
		
func find_distances(start: Vector2i) -> Dictionary:
	var distances: Dictionary = {start: 0}
	var queue: Array[Vector2i] = [start]
	var head = 0
	
	while head < queue.size():
		var current = queue[head]
		head += 1
		
		for direction in DIRECTIONS:
			var next = current + direction
			if next.x < 0 or next.x >= GRID_SIZE:
				continue
			if next.y < 0 or next.y >= GRID_SIZE:
				continue
			if tile_values[next.x][next.y] != 0:
				continue
			
			var between = current + direction / 2
			if tile_values[between.x][between.y] != 0:
				continue
			if distances.has(next):
				continue
			distances[next] = distances[current] + 1
			queue.append(next)
	return distances

func find_farthest_node(distances: Dictionary) -> Vector2i:
	var farthest = Vector2i(0, 0)
	var max_distance = -1
	
	for cell in distances:
		if distances[cell] > max_distance:
			max_distance = distances[cell]
			farthest = cell
			
	return farthest

func place_goal(cell: Vector2i):
	if goal_scene == null:
		return
	var goal = goal_scene.instantiate()
	add_child(goal)
	goal.position = map_to_local(cell)
	occupied[cell] = true
	pass


func get_available_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var cell = Vector2i(x, y)

			if tile_values[x][y] == 0 and not occupied.has(cell):
				if x >= 3 or y >= 3:
					cells.append(cell)

	cells.shuffle()
	return cells


func spawn_powerups() -> void:
	if powerup_scene == null:
		return

	if powerup_ids.is_empty():
		return

	var cells = get_available_cells()
	var amount = mini(powerup_count, cells.size())

	for i in range(amount):
		var cell = cells.pop_back()
		var powerup = powerup_scene.instantiate()
		var powerup_id = powerup_ids.pick_random()
		
		powerup.set("powerup_id", powerup_id)
		add_child(powerup)
		powerup.position = map_to_local(cell)
		occupied[cell] = true


func spawn_normal_enemies() -> void:
	if rat_scene == null:
		return

	var cells = get_available_cells()
	var amount = mini(rat_count, cells.size())

	for i in range(amount):
		var cell = cells.pop_back()
		var enemy = rat_scene.instantiate()

		add_child(enemy)
		enemy.position = map_to_local(cell)

		var path = make_patrol_path(cell, move_num)
		enemy.set("enemy_path", path)

		occupied[cell] = true


func make_patrol_path(start: Vector2i, steps: int) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var forward_path: Array[Vector2] = []
	var current = start

	for i in range(maxi(steps, 1)):
		var possible: Array[Vector2i] = []

		for direction in ENEMY_DIRECTIONS:
			var next = current + direction

			if next.x < 0 or next.x >= GRID_SIZE:
				continue
			if next.y < 0 or next.y >= GRID_SIZE:
				continue
			if tile_values[next.x][next.y] != 0:
				continue

			possible.append(direction)

		if possible.is_empty():
			break

		var direction = possible.pick_random()
		forward_path.append(Vector2(direction))
		current += direction

	path.append_array(forward_path)

	for i in range(forward_path.size() - 1, -1, -1):
		path.append(-forward_path[i])

	return path


func spawn_flying_enemies() -> void:
	if bat_scene == null:
		return

	var cells = get_available_cells()
	var amount = mini(bat_count, cells.size())

	for i in range(amount):
		var cell = cells.pop_back()
		var enemy = bat_scene.instantiate()

		add_child(enemy)
		enemy.position = map_to_local(cell)

		occupied[cell] = true
