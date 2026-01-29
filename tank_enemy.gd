extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")

var isAttack := false
var speed := 170
var hp = 75
var damage := 10

func _ready():
	$animasiTank.play("Walk")


func _physics_process(_delta):
	if player == null:
		return
		
	if hp <= 0:
		die()
		return

	var dir = (player.position - position).normalized()
	$animasiTank.flip_h = dir.x < 0

	if isAttack:
		if $animasiTank.animation != "Attack":
			$animasiTank.play("Attack")
		velocity = Vector2.ZERO
	else:
		if $animasiTank.animation != "Walk":
			$animasiTank.play("Walk")
		velocity = dir * speed

	move_and_slide()





func die():
	$animasiTank.play("Death")
	await $animasiTank.animation_finished
	queue_free()

func _on_area_2d_body_entered(body):
	if body == player:
		isAttack = true
		if body.has_method("takeDamage"):
			body.takeDamage(damage)
			print("Tank enemy hit player")

func _on_area_2d_body_exited(body):
	if body == player:
		isAttack = false
