extends CharacterBody2D

@onready var player = $"../../Player"

var isAttack := false
var speed := 100
var hp = 50
var damage = 2

func death():
	if hp <= 0:
		queue_free()
		print("regular enemy death")
		
func _physics_process(_delta):
	if player == null:
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
	death()

func _on_area_2d_body_entered(body):
	if body == player:
		isAttack = true
		body.takeDamage(damage)

func _on_area_2d_body_exited(body):
	if body == player:
		isAttack = false
