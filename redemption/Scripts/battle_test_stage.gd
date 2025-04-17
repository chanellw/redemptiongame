extends Node2D

@export var player_1_scene: PackedScene
@export var player_2_scene: PackedScene

func _ready():
	var spawn_points = $SpawnPoints.get_children()
	if spawn_points.size() < 2:
		push_error("You need at least 2 spawn points.")
		return

	spawn_points.shuffle()

	# Spawn Player 1 at first spawn point
	var p1_spawn = spawn_points[0]
	var player_1 = player_1_scene.instantiate()
	player_1.position = p1_spawn.global_position
	player_1.original_spawn_position = player_1.position
	add_child(player_1)

	# Spawn Player 2 at second spawn point
	var p2_spawn = spawn_points[1]
	var player_2 = player_2_scene.instantiate()
	player_2.position = p2_spawn.global_position
	player_2.original_spawn_position = player_2.position
	add_child(player_2)
