extends CharacterBody2D


@export var player_path : NodePath
@onready var player = get_node(player_path)

var speed = 100

func _physics_process(delta):
	var dir = (player.position - position).normalized()
	$AnimatedSprite2D.play("Walk")
	if player.position.x - position.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

	move_and_collide(dir * speed * delta)
