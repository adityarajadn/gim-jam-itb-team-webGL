extends Node2D

@onready var animation_player: AnimationPlayer = $body/AnimationPlayer
@onready var player = $"../Player"

func _ready() -> void:
	animation_player.play("idle")
	
func _on_collect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		
		var success = player.add_item("antidote")
		if not success:
			return   # inventory penuh
		
		animation_player.play("collected")
		await animation_player.animation_finished
		queue_free()
