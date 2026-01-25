extends Node2D

@onready var animation_player: AnimationPlayer = $body/AnimationPlayer
@onready var player = $"../Player"
var itemIndex = 1

func _ready() -> void:
	animation_player.play("idle")
	
func _on_collect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		
		animation_player.play("collected")
		player.hasAntidote = true
		#print(player.hasAntidote)
		await animation_player.animation_finished
		
		queue_free()
	pass # Replace with function body.
