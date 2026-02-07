extends CharacterBody2D

# Movement properties
@export var speed: float = 300.0
@export var focus_speed: float = 150.0  # Slower speed when focused
@export var acceleration: float = 2000.0
@export var friction: float = 1500.0
@export var health: int = 20

# Shooting properties
@export var bullet_scene: PackedScene  # Assign your bullet scene in the inspector
@export var fire_rate: float = 0.1  # Time between shots
@export var focused_fire_rate: float = 0.08  # Faster when focused
@export var rotate_to_mouse: bool = true  # Toggle mouse rotation
@export var relative_movement: bool = false  # Movement relative to player rotation (SET TO FALSE)

# Player state
var can_shoot: bool = true
var is_focused: bool = false

# Hitbox
@onready var hitbox: Area2D = $Hitbox
@onready var sprite: Sprite2D = $Sprite2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint

# Signals
signal player_hit
signal player_died

func _ready() -> void:
	# Setup shoot timer
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	# Connect hitbox signals
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta: float) -> void:
	handle_input()
	handle_rotation()  # Handle player rotation
	handle_movement(delta)
	handle_shooting()
	move_and_slide()
	clamp_to_screen()

func handle_input() -> void:
	# Check if player is focusing (typically Shift key in bullet hell games)
	is_focused = Input.is_action_pressed("focus")

func handle_rotation() -> void:
	if rotate_to_mouse:
		# Get mouse position
		var mouse_pos = get_global_mouse_position()
		
		# Calculate angle to mouse
		var angle_to_mouse = global_position.direction_to(mouse_pos).angle()
		
		# Rotate player (add PI/2 because sprites usually face up by default)
		rotation = angle_to_mouse + PI/2

func handle_movement(delta: float) -> void:
	# Get input direction
	var input_direction := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	
	# If relative_movement is enabled, rotate input based on player rotation
	if relative_movement and rotate_to_mouse:
		# Rotate the input direction to match player's facing direction
		input_direction = input_direction.rotated(rotation - PI/2)
	
	# Determine current speed based on focus state
	var current_speed := focus_speed if is_focused else speed
	
	# Apply movement
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * current_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func handle_shooting() -> void:
	# Auto-fire when holding shoot button
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot() -> void:
	if not bullet_scene:
		push_warning("Bullet scene not assigned to player!")
		return
	
	can_shoot = false
	shoot_timer.wait_time = focused_fire_rate if is_focused else fire_rate
	shoot_timer.start()
	
	# Calculate direction (based on player rotation or mouse)
	var direction: Vector2
	if rotate_to_mouse:
		# Shoot in the direction player is facing
		# Get the direction from player position to mouse
		var mouse_pos = get_global_mouse_position()
		direction = global_position.direction_to(mouse_pos)
	else:
		direction = Vector2.UP  # Default straight up
	
	# Spawn bullet
	var bullet = bullet_scene.instantiate()
	if shoot_point:
		bullet.global_position = shoot_point.global_position
	else:
		bullet.global_position = global_position + Vector2(0, -30)
	
	# Pass direction to bullet
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction)
	
	# Add bullet to scene
	get_parent().add_child(bullet)
	
	# Optional: Add additional bullets for focused shot pattern
	if is_focused:
		spawn_focused_pattern()

func spawn_focused_pattern() -> void:
	# Create a focused shot pattern
	# Override this method to create your own pattern
	pass

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func clamp_to_screen() -> void:
	# Keep player within screen bounds
	var screen_size := get_viewport_rect().size
	var margin := 20  # Pixels from edge
	
	global_position.x = clamp(global_position.x, margin, screen_size.x - margin)
	global_position.y = clamp(global_position.y, margin, screen_size.y - margin)

func _on_hitbox_area_entered(area: Area2D) -> void:
	# Check if hit by enemy bullet
	if area.is_in_group("enemy_bullets"):
		take_damage()

func take_damage() -> void:
	player_hit.emit()
	health -= 1
	if health <= 0:
		die()

func die() -> void:
	player_died.emit()
	# Add death animation, restart logic, etc.
	queue_free()

# Helper function to get the hitbox visibility (for debugging)
func _process(_delta: float) -> void:
	if is_focused and hitbox:
		# Make hitbox visible when focused (optional visual feedback)
		hitbox.modulate = Color(1, 0, 0, 0.3)
	elif hitbox:
		hitbox.modulate = Color(1, 1, 1, 0)
