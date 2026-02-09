extends CharacterBody2D
class_name Player

# Movement properties
@export var speed: float = 300.0
@export var focus_speed: float = 150.0
@export var acceleration: float = 2000.0
@export var friction: float = 1500.0
@export var max_health: int = 20  # Added max_health
var health: int  # Changed from @export

# Shooting properties
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.1
@export var focused_fire_rate: float = 0.08
@export var rotate_to_mouse: bool = true
@export var relative_movement: bool = false

# Player state
var can_shoot: bool = true
var is_focused: bool = false

# Hitbox
@onready var hitbox: Area2D = $Hitbox
@onready var sprite: Sprite2D = $Sprite2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_point: Marker2D = $ShootPoint
@onready var fps = $"../CanvasLayer/fps"


# Signals
signal player_hit
signal player_died

func _ready() -> void:
	# Initialize health
	health = max_health
	
	# Add player to group so drones can find it
	add_to_group("player")
	
	# Setup shoot timer
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	# Connect hitbox signals
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta: float) -> void:
	handle_input()
	handle_rotation()
	handle_movement(delta)
	handle_shooting()
	move_and_slide()
	clamp_to_screen()

func handle_input() -> void:
	is_focused = Input.is_action_pressed("focus")

func handle_rotation() -> void:
	if rotate_to_mouse:
		var mouse_pos = get_global_mouse_position()
		var angle_to_mouse = global_position.direction_to(mouse_pos).angle()
		rotation = angle_to_mouse + PI/2

func handle_movement(delta: float) -> void:
	var input_direction := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	
	if relative_movement and rotate_to_mouse:
		input_direction = input_direction.rotated(rotation - PI/2)
	
	var current_speed := focus_speed if is_focused else speed
	
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * current_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func handle_shooting() -> void:
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot() -> void:
	if not bullet_scene:
		push_warning("Bullet scene not assigned to player!")
		return
	
	can_shoot = false
	shoot_timer.wait_time = focused_fire_rate if is_focused else fire_rate
	shoot_timer.start()
	
	var direction: Vector2
	if rotate_to_mouse:
		var mouse_pos = get_global_mouse_position()
		direction = global_position.direction_to(mouse_pos)
	else:
		direction = Vector2.UP
	
	var bullet = bullet_scene.instantiate()
	if shoot_point:
		bullet.global_position = shoot_point.global_position
	else:
		bullet.global_position = global_position + Vector2(0, -30)
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction)
	
	get_parent().add_child(bullet)
	
	if is_focused:
		spawn_focused_pattern()

func spawn_focused_pattern() -> void:
	pass

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func clamp_to_screen() -> void:
	var screen_size := get_viewport_rect().size
	var margin := 20
	
	global_position.x = clamp(global_position.x, margin, screen_size.x - margin)
	global_position.y = clamp(global_position.y, margin, screen_size.y - margin)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_bullets") or area.is_in_group("enemies"):
		take_damage()

func take_damage() -> void:
	health -= 1
	print("Player hit! Health:", health)
	player_hit.emit()  # Emit AFTER changing health
	
	if health <= 0:
		die()

func die() -> void:
	player_died.emit()
	print("Player died!")
	queue_free()

func _process(_delta: float) -> void:
	fps.text = str(Engine.get_frames_per_second())
	if is_focused and hitbox:
		hitbox.modulate = Color(1, 0, 0, 0.3)
	elif hitbox:
		hitbox.modulate = Color(1, 1, 1, 0)
