extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var area_attack: CollisionShape2D = $"area attack/CollisionShape2D"


var isAttack := false
var speed := 60
var hp = 100
var damage = 15

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
		area_attack.disabled = false
		if $animasiTank.animation != "Attack":
			$animasiTank.play("Attack")
		velocity = Vector2.ZERO
	else:
		if $animasiTank.animation != "Walk":
			$animasiTank.play("Walk")
		area_attack.disabled = true
		velocity = dir * speed

	move_and_slide()
	death()

func _on_area_2d_body_entered(body):
	if body == player:
		isAttack = true

func _on_area_2d_body_exited(body):
	if body == player:
		isAttack = false

func _on_area_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and isAttack:
		body.takeDamage(damage)
	pass # Replace with function body.
