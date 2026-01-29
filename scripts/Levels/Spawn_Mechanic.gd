extends Node

@export var min_radius := 400
@export var max_radius := 700
@export var player : CharacterBody2D
@export var spawn_interval := 0.6
@onready var wave_manager = get_parent()
@export var regular_enemy: PackedScene
@export var ranged_enemy: PackedScene
@export var tank_enemy: PackedScene
var EnemyPool : Array [PackedScene]
var spawn_timer := 0.0

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	
func get_random_spawn_position() -> Vector2:
	var angle = randf() * TAU #TAU biar jadi lingkaran
	var distance = randf_range(min_radius, max_radius)
	return player.global_position + Vector2(cos(angle), sin(angle)) * distance

func spawn_enemy():
	var currentWave = wave_manager.current_wave
	EnemyPool = get_enemy_pool_for_wave(currentWave)
	if EnemyPool.is_empty():
		return
	var enemy = EnemyPool.pick_random().instantiate()
	enemy.global_position = get_random_spawn_position()
	add_child(enemy)

func get_enemy_pool_for_wave(wave: int) -> Array[PackedScene]:
	var pool: Array[PackedScene] = []
	# Buat control musuh yg muncul tiap wave
	pool.append(regular_enemy)
	if wave >= 2:
		pool.append(ranged_enemy)
	if wave >= 4:
		pool.append(tank_enemy)
	return pool

func _process(delta: float) -> void:
	var canSpawn = not wave_manager.in_prep
	if (canSpawn):
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_timer = 0
			spawn_enemy()
