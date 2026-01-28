extends Node2D

@export var item_id := "heal"
@onready var animation_player: AnimationPlayer = $body/AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")

func _on_collect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):

		# Kirim item ke inventory player
		if body.has_method("add_item"):
			var success = body.add_item(item_id)

			# Kalau inventory penuh → jangan hilang
			if success == false:
				return

		# Play animasi collect
		animation_player.play("collected")
		await animation_player.animation_finished
		queue_free()
