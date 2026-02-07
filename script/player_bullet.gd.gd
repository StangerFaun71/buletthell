extends Area2D

@export var speed: float = 600.0
@export var damage: int = 1
@export var max_range: float = 500.0  # Maximum distance the bullet can travel

var direction: Vector2 = Vector2.UP  # Default direction
var distance_traveled: float = 0.0  # Track how far the bullet has traveled
var start_position: Vector2  # Store starting position

func _ready() -> void:
	# Add to bullet group for identification
	add_to_group("player_bullets")
	
	# Store the starting position
	start_position = global_position
	
	# Connect to area entered signal
	area_entered.connect(_on_area_entered)
	
	# Auto-delete after leaving screen
	body_entered.connect(_on_body_entered)
	
	# Rotate sprite to face direction
	rotation = direction.angle() + PI/2  # +PI/2 because sprites usually face up by default

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	# Update rotation when direction is set
	rotation = direction.angle() + PI/2

func _physics_process(delta: float) -> void:
	# Calculate movement this frame
	var movement = direction * speed * delta
	
	# Move bullet in the set direction
	position += movement
	
	# Track distance traveled
	distance_traveled += movement.length()
	
	# Check if bullet has exceeded its range
	if distance_traveled >= max_range:
		queue_free()
		return
	
	# Delete if far off-screen (backup cleanup)
	var screen_size = get_viewport_rect().size
	if position.x < -100 or position.x > screen_size.x + 100 or \
	   position.y < -100 or position.y > screen_size.y + 100:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Hit enemy
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	# Hit something solid
	queue_free()
