extends Node

@export var spawner: Node
@export var prep_time := 7.0
@export var wave_time := 60.0
@export var current_wave := 0
@export var countdown: Label
@export var wave_text: Label

var timer := 0.0
@export var in_prep := true

func clear_all_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.queue_free()
		
func start_wave():
	timer = 0
	in_prep = false
	current_wave += 1
	spawner.spawn_interval = max(0.30, 0.6 - current_wave * 0.05)
	
func end_wave():
	timer = 0
	in_prep = true
	clear_all_enemies()

func _process(delta: float) -> void: 
	if in_prep and timer >= prep_time:
		start_wave()
	elif not in_prep and timer >= wave_time:
		end_wave()
	timer += delta	
	if not in_prep: 
		countdown.text = "%d" % int(60-timer)
		wave_text.text = "Wave : %d" % int (current_wave)
	else:
		countdown.text = "%d" % int(7-timer)
		wave_text.text = "Wave : %d" % int (current_wave)
