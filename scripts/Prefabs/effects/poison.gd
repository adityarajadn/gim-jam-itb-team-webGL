extends Node2D

@onready var player: CharacterBody2D = $"../.."

var damage := 2
var poison_duration := 5.0     # total durasi poison (detik)
var poison_interval := 1.0     # jedeb tiap berapa detik

var poison_timer: Timer
var poison_elapsed := 0.0

func _ready():
	poison_timer = Timer.new()
	poison_timer.wait_time = poison_interval
	poison_timer.one_shot = false
	add_child(poison_timer)
	poison_timer.timeout.connect(_on_poison_tick)

func getPoisoned():
	poison_elapsed = 0
	player.modulate = Color(1.0, 0.0, 0.0, 1.0)
	poison_timer.start()

func _on_poison_tick():
	player.hp -= damage
	poison_elapsed += poison_interval
	
	if poison_elapsed >= poison_duration:
		poison_timer.stop()
		player.effect = ""
		player.modulate = Color(1,1,1,1)
