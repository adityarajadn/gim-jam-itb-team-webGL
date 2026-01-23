extends CharacterBody2D

@export var speed := 200
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_facing := 1   # 1 = right, -1 = left

func _physics_process(_delta):
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		velocity = input_dir * speed
		
		# Update arah hadap hanya dari X
		if input_dir.x != 0:
			last_facing = sign(input_dir.x)
		
		play_run_animation()
	else:
		velocity = Vector2.ZERO
		play_idle_animation()

	move_and_slide()


func play_run_animation():
	if last_facing > 0:
		sprite.play("run_right")
	else:
		sprite.play("run_left")


func play_idle_animation():
	if last_facing > 0:
		sprite.play("idle_right")
	else:
		sprite.play("idle_left")
