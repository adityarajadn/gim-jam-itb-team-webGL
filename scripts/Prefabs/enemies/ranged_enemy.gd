extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D = $AnimasiRange

@export var axe_scene: PackedScene
@export var speed := 60
@export var throw_frame := 2
@export var throw_offset := 20

var player_in_throw_range := false
var attacking := false
var can_throw := false

var hp = 40

func death():
	if hp <= 0:
		queue_free()
		print("range enemy death")
		
func _physics_process(_delta):
	if player == null:
		return

	var to_player = player.global_position - global_position
	var dir = to_player.normalized()

	sprite.flip_h = dir.x < 0

	# Selalu bergerak ke player
	velocity = dir * speed
	
	# Play animasi berdasarkan state
	if player_in_throw_range:
		if not attacking:
			attacking = true
			start_attack_loop()
		if sprite.animation != "Attack":
			sprite.play("Attack")
	else:
		attacking = false
		if sprite.animation != "Walk":
			sprite.play("Walk")

	move_and_slide()
	death()


func start_attack_loop() -> void:
	await async_attack_loop()


func async_attack_loop() -> void:
	while attacking and player != null and player_in_throw_range:
		can_throw = true
		sprite.play("Attack")
		await sprite.animation_finished


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
		get_parent().add_child(axe)

		axe.global_position = global_position + dir * throw_offset
		axe.init(dir)


func _on_throw_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_throw_range = true


func _on_throw_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_throw_range = false
		attacking = false
		can_throw = false
