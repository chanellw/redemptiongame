extends Node2D

@export var space_rocky_scene: PackedScene  # Drag Space_Rocky.tscn here in the editor

func _init():
	randomize()

func _ready():
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	if spawn_points.is_empty():
		print("No spawn points found!")
		return

	var random_spawn = spawn_points[randi() % spawn_points.size()]
	var space_rocky = space_rocky_scene.instantiate()
	space_rocky.position = random_spawn.global_position
	add_child(space_rocky)
