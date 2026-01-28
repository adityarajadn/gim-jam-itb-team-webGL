extends Node2D

@export var item_id := "heal"
@onready var animation_player: AnimationPlayer = $body/AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")

func _on_collect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var success = body.add_item(item_id)
		if not success:
			return  # Inventory penuh
		
		animation_player.play("collected")
		await animation_player.animation_finished
		queue_free()
