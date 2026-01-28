extends CharacterBody2D

@export var speed := 250
@export var camera: Camera2D

@onready var body: AnimatedSprite2D = $"Body AnimatedSprite2D"

var last_facing := 1   # 1 = right, -1 = left
var hp := 100

var inventoryLimit = 2
var hasAntidote := false
var hasFlashLight := false

@export var effect := ""

@onready var poison: Node2D = $Effects/poison
@onready var flash_light: Node2D = $Effects/flashLight

var isPoisonActive := false

var isInvincible := false
@export var invincibleDuration := 0.5

@export var shakeIntensity := 2.0
@export var shakeDuration := 0.2
var isShake := false

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta):
	var input_dir := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

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

	checkEffect()
	cameraShake()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("use_item"):
		useAntidote()

func checkEffect():
	if effect == "poison" and not isPoisonActive:
		isPoisonActive = true
		poison.getPoisoned()

	elif effect != "poison" and isPoisonActive:
		isPoisonActive = false
		poison.poison_timer.stop()
		poison.poison_elapsed = 0
		modulate = Color.WHITE

func takeDamage(damage: int):
	if isInvincible or hp <= 0:
		return

	hp -= damage
	hp = max(hp, 0)

	startCameraShake()

	isInvincible = true
	modulate = Color(1, 0.5, 0.5)

	await get_tree().create_timer(invincibleDuration).timeout

	modulate = Color.WHITE
	isInvincible = false

	if hp <= 0:
		die()

func die():
	set_physics_process(false)
	velocity = Vector2.ZERO
	body.play("idle_right") # ganti animasi death kalau ada
	print("PLAYER DEAD")

func startCameraShake():
	if isShake:
		return

	isShake = true
	await get_tree().create_timer(shakeDuration).timeout
	isShake = false
	camera.offset = Vector2.ZERO

func cameraShake():
	if isShake:
		camera.offset = Vector2(
			randf_range(-shakeIntensity, shakeIntensity),
			randf_range(-shakeIntensity, shakeIntensity)
		)
	else:
		camera.offset = Vector2.ZERO

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		pass

func useAntidote():
	if not hasAntidote:
		return

	hasAntidote = false

	if effect == "poison":
		effect = ""
		isPoisonActive = false
		poison.poison_timer.stop()
		poison.poison_elapsed = 0
		modulate = Color.WHITE

func useFlashLight():
	if not hasFlashLight:
		return
	flash_light.flashLightEffect()
	hasFlashLight = false

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
