extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")

var isAttack := false
var speed := 200
var hp = 50
var damage := 5

func _ready():
	add_to_group("Enemies")

func _physics_process(_delta):
	if player == null:
		return
		
	if hp <= 0:
		die()
		return

	var dir = (player.position - position).normalized()
	$animasiRegular.flip_h = dir.x < 0

	if isAttack:
		if $animasiRegular.animation != "Attack":
			$animasiRegular.play("Attack")
		velocity = Vector2.ZERO
	else:
		if $animasiRegular.animation != "Walk":
			$animasiRegular.play("Walk")
		velocity = dir * speed

	move_and_slide()



func die():
	$animasiRegular.play("Death")
	await $animasiRegular.animation_finished
	queue_free()

func _on_area_2d_body_entered(body):
	if body == player:
		isAttack = true
		if body.has_method("takeDamage"):
			body.takeDamage(damage)
			print("Regular enemy hit player")

func _on_area_2d_body_exited(body):
	if body == player:
		isAttack = false
