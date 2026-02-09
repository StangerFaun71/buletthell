extends TextureProgressBar

@export var player: Player
@onready var kutya = $kutya

func _ready() -> void:
	# If player isn't assigned, try to find it
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if player:
		# Set values explicitly
		min_value = 0.0
		max_value = float(player.max_health)
		value = float(player.health)
		step = 1.0
		
		# Connect signals
		player.player_hit.connect(update_health_bar)
		player.player_died.connect(update_health_bar)
		
		# Update label
		kutya.text = str(player.health)
		
		# Force update
		update_health_bar()
		
	else:
		push_error("Player not found!")

func update_health_bar() -> void:
	if player:
		value = float(player.health)
		kutya.text = str(player.health) + "/" + str(player.max_health)
		print("HP Update - value:", value, " max:", max_value, " ratio:", value/max_value)

# Add this for real-time testing
func _process(_delta: float) -> void:
	if player and is_instance_valid(player):
		value = float(player.health)
		kutya.text = str(player.health)
