extends Node2D

var Room = preload("res://Room.tscn")
var Player = preload("res://Player.tscn")
var Enemy = preload("res://Enemy.tscn")
var font = preload("res://Font/roboto-bold.tres")
onready var Rooms = get_node('/root/MainScene/Rooms')
onready var Map : TileMap = get_node('/root/MainScene/TileMap')
onready var ui = get_node('/root/MainScene/CanvasLayer/UI')

var tile_size = 16  # size of a tile in the TileMap
var num_rooms = 20  # number of rooms to generate
var min_size = 10  # minimum room size (in tiles)
var max_size = 20  # maximum room size (in tiles)
var hspread = 400  # horizontal spread
var cull = 0.4 # chance to cull room

var path  # AStar pathfinding object
var start_room = null
var end_room = null
var play_mode = false
var player = null
var enemy = null

func _ready():
	randomize()

func _draw():
	if start_room:
		draw_string(font, start_room.position-Vector2(125,0), "start", Color(1,1,1))
	if end_room:
		draw_string(font, end_room.position-Vector2(125,0), "end", Color(1,1,1))
	if play_mode:
		return
	for room in Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2),
				 Color(0, 1, 0), false)
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y),
						  Color(1, 1, 0), 15, true)

func _process(delta):
	update()

func _input(event):
	if event.is_action_pressed('ui_select'):
		ui.showLoadScreen()
		if play_mode:
			player.queue_free()
			play_mode = false
		for n in Rooms.get_children():
			n.queue_free()
		path = null
		start_room = null
		end_room = null
		make_rooms()
#	if event.is_action_pressed('ui_focus_next'):
#		make_map()
#	if event.is_action_pressed('ui_cancel'):
#		spawn_player()

func activate():
	make_rooms()

func spawn_player():
	ui.hideLoadScreen()
	player = Player.instance()
	add_child(player)
	player.position = start_room.position
	play_mode = true
	for r in Rooms.get_children():
		# if start room then don't spawn mob
		if r.position != start_room.position:
			spawn_mob(r.position)

func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(rand_range(-hspread, hspread), 0)
		var r = Room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		Rooms.add_child(r)
	# wait for movement to stop
	yield(get_tree().create_timer(1.1), 'timeout')
	# cull rooms
	var room_positions = []
	for room in Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			room_positions.append(Vector3(room.position.x, room.position.y, 0))
	yield(get_tree(), 'idle_frame')
	# generate spanning tree (path)
	path = find_mst(room_positions)
	yield(get_tree().create_timer(1), "timeout")
	make_map()
	spawn_player()

func find_mst(nodes):
	# Prim's algorithm
	# Given an array of positions (nodes), generates a minimum
	# spanning tree
	# Returns an AStar object

	# Initialize the AStar and add the first point
	var path = AStar.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())

	# Repeat until no more nodes remain
	while nodes:
		var min_dist = INF  # Minimum distance found so far
		var min_p = null  # Position of that node
		var p = null  # Current position
		# Loop through the points in the path
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			# Loop through the remaining nodes in the given array
			for p2 in nodes:
				# If the node is closer, make it the closest
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		# Insert the resulting node into the path and add
		# its connection
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		# Remove the node from the array so it isn't visited again
		nodes.erase(min_p)
	return path

func make_map():
	# Creates a TileMap from the generated rooms & path
	find_start_room()
	find_end_room()
	Map.clear()

	# Fill TileMap with walls and carve out empty spaces
	var full_rect = Rect2()
	for room in Rooms.get_children():
		var r = Rect2(room.position-room.size,
					room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(x, y, 78)

	# Carve rooms
	for room in Rooms.get_children():
		var s = (room.size / tile_size).floor() # number of tiles in room
		var pos = Map.world_to_map(room.position) # pos of room in world
		var ul = (room.position / tile_size).floor() - s
		var xMax = (s.x * 2 - 2)
		var yMax = (s.y * 2 - 2)
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				# left most wall of room
				if(x == 2):
					Map.set_cell(ul.x + x, ul.y + y, 0)
				# top of room
				elif(y == 2):
					Map.set_cell(ul.x + x, ul.y + y, rand_range(1,4))
				# bottom of room
				elif(y == yMax):
					Map.set_cell(ul.x + x, ul.y + y, rand_range(41,44))
				# right most wall of room
				elif(x == xMax):
					Map.set_cell(ul.x + x, ul.y + y, 5)
				# the rest of the room
				else:
					Map.set_cell(ul.x + x, ul.y + y, rand_range(26,29))


		# Carve connecting corridor
		var p = path.get_closest_point(
			Vector3(
				room.position.x, room.position.y, 0
			)
		)

		var corridors = []  # One corridor per connection
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.world_to_map(
					Vector2(
						path.get_point_position(p).x,
						path.get_point_position(p).y
					)
				)
				var end = Map.world_to_map(
					Vector2(
						path.get_point_position(conn).x,
						path.get_point_position(conn).y
					)
				)
				carve_path(start, end)
		corridors.append(p)

func carve_path(pos1, pos2):
	# Carves a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0:
		x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0:
		y_diff = pow(-1.0, randi() % 2)
	# Carve either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	var tileRangeStart = 69
	var tileRangeEnd = 69
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
#		print_debug(str("x: ", x, " - " , x_y.y))
		Map.set_cell(x, x_y.y, rand_range(tileRangeStart, tileRangeEnd))
		Map.set_cell(x, x_y.y+y_diff, rand_range(tileRangeStart, tileRangeEnd))  # widen the corridor
		Map.set_cell(x, x_y.y+y_diff*2, rand_range(tileRangeStart, tileRangeEnd))  # widen the corridor
		Map.set_cell(x, x_y.y+y_diff*3, rand_range(tileRangeStart, tileRangeEnd))  # widen the corridor
	for y in range(pos1.y, pos2.y, y_diff):
#		print_debug("y: ", y, " - ", y_x.x)
		Map.set_cell(y_x.x, y, rand_range(tileRangeStart, tileRangeEnd))
		Map.set_cell(y_x.x+x_diff, y, rand_range(tileRangeStart, tileRangeEnd))  # widen the corridor
		Map.set_cell(y_x.x+x_diff*2, y, rand_range(tileRangeStart, tileRangeEnd))  # widen the corridor
		Map.set_cell(y_x.x+x_diff*3, y, rand_range(tileRangeStart, tileRangeEnd))  # widen the corridor

func find_start_room():
	var min_x = INF
	for room in Rooms.get_children():
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x

func find_end_room():
	var max_x = -INF
	for room in Rooms.get_children():
		if room.position.x > max_x:
			end_room = room
			max_x = room.position.x

func spawn_mob(position):
	enemy = Enemy.instance()
	add_child(enemy)
	enemy.position = position
	return
