extends Node2D

@onready var fog: Sprite2D = $"../../fog"

func flashLightEffect():
	var default = fog.modulate.a
	fog.modulate.a = 0.5
	await get_tree().create_timer(5).timeout
	fog.modulate.a = default
