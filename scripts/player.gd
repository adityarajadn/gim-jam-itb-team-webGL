extends CharacterBody2D

@export var speed := 250
@export var punch_cooldown := 0.7   # detik

@onready var body: AnimatedSprite2D = $"Body AnimatedSprite2D"
@onready var hands: AnimatedSprite2D = $"Hands AnimatedSprite2D"

var last_facing := 1   # 1 = right, -1 = left
var is_punching := false
var can_punch := true


func _ready():
	hands.visible = false
	
	# Pastikan animasi punch tidak loop
	for anim in hands.sprite_frames.get_animation_names():
		if anim.begins_with("punch"):
			hands.sprite_frames.set_animation_loop(anim, false)
	
	hands.animation_finished.connect(_on_hand_finished)


func _physics_process(_delta):

	# =====================
	# LOCK MOVEMENT SAAT PUNCH
	# =====================
	if is_punching:
		velocity = Vector2.ZERO
		move_and_slide()
	else:
		var input_dir = Vector2.ZERO
		input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")

		if input_dir != Vector2.ZERO:
			input_dir = input_dir.normalized()
			velocity = input_dir * speed
			
			if input_dir.x != 0:
				last_facing = sign(input_dir.x)
			
			play_run_animation()
		else:
			velocity = Vector2.ZERO
			play_idle_animation()

		move_and_slide()

	# =====================
	# INPUT PUNCH + COOLDOWN
	# =====================
	if can_punch and (Input.is_action_just_pressed("m1") or Input.is_action_just_pressed("m2")):
		start_punch()


# =====================
# BODY ANIMATION
# =====================

func play_run_animation():
	if last_facing > 0:
		body.play("run_right")
	else:
		body.play("run_left")


func play_idle_animation():
	if last_facing > 0:
		body.play("idle_right")
	else:
		body.play("idle_left")


func play_nohands_animation():
	if last_facing > 0:
		body.play("nohands_right")
	else:
		body.play("nohands_left")


# =====================
# HANDS (PUNCH)
# =====================

func start_punch():
	if not can_punch:
		return
		
	can_punch = false
	is_punching = true
	hands.visible = true
	
	# Ganti body ke no-hands
	play_nohands_animation()
	
	if last_facing > 0:
		hands.play("punch_right")
	else:
		hands.play("punch_left")
	
	start_cooldown()


func _on_hand_finished():
	is_punching = false
	hands.visible = false
	
	# Balikin animasi body sesuai kondisi terakhir
	if velocity.length() > 0:
		play_run_animation()
	else:
		play_idle_animation()


func start_cooldown():
	await get_tree().create_timer(punch_cooldown).timeout
	can_punch = true
