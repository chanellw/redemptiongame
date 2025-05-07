extends StaticBody2D

@onready var collision_shape = [$Platform, $Platform2, $Platform3]  # Reference the platform's collision shape

func _ready():
	collision_shape[0].one_way_collision = true  # Enable one-way collision for the platform
	collision_shape[1].one_way_collision = true  # Enable one-way collision for the platform
	collision_shape[2].one_way_collision = true  # Enable one-way collision for the platform
