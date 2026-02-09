extends Node2D
@export var p1: Vector2 = Vector2(2,2)
@export var p2: Vector2 = Vector2(1490,880)
@onready var enemy: Resource = preload("res://sene/drone.tscn")
@onready var timer = $Timer


func get_random_point(p1: Vector2, p2: Vector2) -> Vector2:
	var y_value: float = randf_range(p1.y, p2.y)
	var x_value: float = randf_range(p1.x, p2.x)


	var random_point: Vector2 = Vector2(x_value,y_value)
	return (random_point)

func spawn_enemy() -> void:
	var enemy_instance:Node = enemy.instantiate()
	add_child(enemy_instance)
	var spawn_point: Vector2 = get_random_point(p1, p2)
	enemy_instance.set_position(spawn_point)

func _ready() -> void:
	randomize()

func _process(delta):
	if timer and not timer.timeout.is_connected(spawn_enemy):
		timer.timeout.connect(spawn_enemy)
