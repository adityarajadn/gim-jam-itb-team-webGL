extends Node2D

@onready var player = $"../Player"
@onready var animation_player: AnimationPlayer = $body/AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")
	
func _on_collect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		animation_player.play("collected")
		player.hasFlashLight = true
		
		await animation_player.animation_finished
		
		queue_free()
	pass # Replace with function body.
	
