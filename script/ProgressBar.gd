extends TextureProgressBar

@export var player: Player
@onready var kutya = $kutya
@onready var label = $"../TextureRect/VBoxContainer/Label"

func _ready() -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if player:
		player.player_hit.connect(update_health_bar)
		player.player_died.connect(update_health_bar)
		
		max_value = player.max_health
		value = player.health
		kutya.text = str(player.health) + "/" + str(player.max_health)
		label.text = "HP:" + str(player.max_health)
		# Add visual feedback with tint (if using textures)

	else:
		push_error("Player not found!")

func update_health_bar() -> void:
	if player:
		value = player.health
		kutya.text = str(player.health) + "/" + str(player.max_health)
		
	
