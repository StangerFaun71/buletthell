extends Area2D

@export var health: int = 5
@export var speed: float = 100.0
@export var explosion_scene: PackedScene
@export var collision_damage: int = 1

var player: CharacterBody2D

func _ready() -> void:
	add_to_group("enemies")
	area_entered.connect(_on_area_entered)
	
	# Find player automatically
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		push_warning("Drone couldn't find player!")

func _process(delta: float) -> void:
	if player and is_instance_valid(player):
		var direction := global_position.direction_to(player.global_position)
		global_position += direction * speed * delta

func take_damage(amount: int) -> void:
	health -= amount
	print("Drone hit! Health:", health)
	if health <= 0:
		die()

func die() -> void:
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_parent().add_child(explosion)
	print("Drone destroyed!")
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Check if we hit the player's hitbox
	if area.name == "Hitbox":
		var parent = area.get_parent()
		if parent is Player and parent.has_method("take_damage"):
			parent.take_damage()
			die()  # Drone is destroyed on contact
