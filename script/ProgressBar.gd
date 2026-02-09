extends TextureProgressBar

@export var player: Player
@export var max_health: int = 20
@onready var kutya = $kutya


func _ready() -> void:
	if player:
		player.player_hit.connect(update_health_bar)
		player.player_died.connect(update_health_bar)
		max_value = max_health
		kutya.text = int(max_value)
		update_health_bar()

func update_health_bar() -> void:
	if player:
		value = player.health
		kutya.text = int(value)


