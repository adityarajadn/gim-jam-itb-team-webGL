extends Node2D

var bullet_path = preload("uid://bdpnrs7l6jctp")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var bullet_spawn_position: Node2D = $body/bulletSpawnPosition
@onready var body: Node2D = $body

var isOnPlayer = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body.position = Vector2(0,0)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isOnPlayer:
		look_at(get_global_mouse_position())
		getFireInput()
		checkOnPlayer()
		checkAngle()

func getFireInput():
	if Input.is_action_just_pressed("m1"):
		spawnBullet()
		
func spawnBullet():
	var bullet = bullet_path.instantiate()
	bullet.dir = rotation
	bullet.pos = bullet_spawn_position.global_position
	bullet.rot = global_rotation
	get_parent().add_child(bullet)

func checkOnPlayer():
	if isOnPlayer == true:
		global_position = player.global_position
		body.position = Vector2(50,0)

func checkAngle():
	if rotation > PI / 2 or rotation < -PI / 2:
		body.scale.y = -1
	else:
		body.scale.y = 1

func _on_collect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		isOnPlayer = true
	pass # Replace with function body.
