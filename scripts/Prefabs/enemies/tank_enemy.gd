extends CharacterBody2D

@onready var player = $"../../Player"

var isAttack := false
var speed := 60
var hp = 100

func death():
	if hp <= 0:
		queue_free()
		print("tank death")
		
func _ready():
	$animasiTank.play("Walk")

func _physics_process(_delta):
	if player == null:
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
	death()


func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()


func die():
	isAttack = false
	velocity = Vector2.ZERO
	$animasiTank.play("Death")
	await $animasiTank.animation_finished
	queue_free()

func _on_area_2d_body_entered(body):
	if body == player:
		isAttack = true

func _on_area_2d_body_exited(body):
	if body == player:
		isAttack = false
