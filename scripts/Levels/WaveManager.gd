extends Node

@export var spawner: Node
@export var prep_time := 7.0
@export var wave_time := 60.0
@export var current_wave := 0
var timer := 0.0
var in_prep := true

func start_wave():
	timer = 0
	in_prep = false
	current_wave += 1
	spawner.spawn_interval = max(0.15, 0.6 - current_wave * 0.05)
	
func end_wave():
	timer = 0
	in_prep = true

func _process(delta: float) -> void:
	timer += delta
	if in_prep and timer >= prep_time:
		start_wave()
	elif not in_prep and timer >= wave_time:
		end_wave()
