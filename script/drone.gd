extends Area2D

@export var health: int = 5
@export var speed: float = 100.0
@export var player: Player
@export var explosion_scene: PackedScene

func _ready() -> void:
	# Ensure bullets can detect this as an enemy
	add_to_group("enemies")

func _process(delta: float) -> void:
	if player:
		var direction := global_position.direction_to(player.global_position)
		global_position += direction * speed * delta

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	# Spawn explosion if provided
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_parent().add_child(explosion)
	queue_free()

func _on_body_entered(_body: Node) -> void:
	pass
