extends CharacterBody2D

@export var speed := 250

@onready var body: AnimatedSprite2D = $"Body AnimatedSprite2D"
#@onready var hands: AnimatedSprite2D = $"Hands AnimatedSprite2D"
@onready var camera: Camera2D = $Camera2D

var last_facing := 1   # 1 = right, -1 = left

#----Player Stats----
var hp = 100
var inventoryLimit = 2
var hasAntidote = false
var hasFlashLight = false
@export var effect = ""

#----Effect Lib----
@onready var poison: Node2D = $Effects/poison
var isPoisonActive = false
@onready var flash_light: Node2D = $Effects/flashLight

#----Camera----
var shakeIntensity = 2
var shakeDuration = 0.2
var isShake = false

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta):
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
	checkEffect()
	cameraShake()
	useFlashLight()
	
	#print("Antidote:", hasAntidote, "Effect:", effect) #debug antidote dan effect

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("use_item"):
		useAntidote()
		
#----Effects----
func checkEffect():
	if effect == "poison" and not isPoisonActive:
		isPoisonActive = true
		poison.getPoisoned()
	elif effect != "poison" and isPoisonActive:
		isPoisonActive = false
		poison.poison_timer.stop()
		pass
		
		
		
#----Animation----

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


#----Camera----
func cameraShake():
	if isShake == true:
		camera.offset = Vector2(
			randf_range(-shakeIntensity, shakeIntensity),
			randf_range(-shakeIntensity, shakeIntensity)
		)
		
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		isShake = true
		await get_tree().create_timer(shakeDuration).timeout
		isShake = false
	pass # Replace with function body.

#---Antidote----
func useAntidote():
	if not hasAntidote:
		return
	
	hasAntidote = false
	
	if effect == "poison":
		effect = ""
		isPoisonActive = false
		
		poison.poison_timer.stop()
		poison.poison_elapsed = 0
		
		modulate = Color(1,1,1,1)  # reset warna
		
#----Flash Light----
func useFlashLight():
	if not hasFlashLight:
		return
	
	hasFlashLight = false
	flash_light.flashLightEffect()
