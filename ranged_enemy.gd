extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D = $AnimasiRange

@export var axe_scene: PackedScene
@export var attack_range := 500
@export var speed := 150
@export var throw_frame := 2
@export var throw_offset := 20

var attacking := false
var can_throw := true
var hp := 40

func _ready():
	add_to_group("Enemies")

func _physics_process(_delta):
	if hp <= 0:
		die()
		return
	
	if player == null:
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()
	var dir = to_player.normalized()

	sprite.flip_h = dir.x < 0

	if distance > attack_range:
		attacking = false
		can_throw = true
		velocity = dir * speed
		if sprite.animation != "Walk":
			sprite.play("Walk")
	else:
		velocity = Vector2.ZERO
		if not attacking:
			attacking = true
			start_attack_loop()

	move_and_slide()


func start_attack_loop() -> void:
	async_attack_loop()


func async_attack_loop() -> void:
	while attacking \
	and player != null \
	and global_position.distance_to(player.global_position) <= attack_range:

		can_throw = true
		sprite.play("Attack")
		await sprite.animation_finished
		await get_tree().create_timer(1.0).timeout


func _on_animasi_range_frame_changed() -> void:
	if not attacking:
		return

	if sprite.animation != "Attack":
		return

	if sprite.frame == throw_frame and can_throw:
		can_throw = false

		if axe_scene == null:
			push_error("axe_scene belum di-set")
			return

		var dir = (player.global_position - global_position).normalized()
		var axe = axe_scene.instantiate()
		
		# Set position dan direction SEBELUM add_child
		axe.global_position = global_position + dir * throw_offset
		axe.direction = dir  # Set direction langsung sebelum add
		
		get_parent().add_child(axe)
		
		print("Axe spawned with direction:", dir)

func die():
	
	sprite.play("Death")
	await sprite.animation_finished
	queue_free()
