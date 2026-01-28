extends CharacterBody2D

@export var speed := 250
@export var camera: Camera2D

@onready var body: AnimatedSprite2D = $"Body AnimatedSprite2D"

# HUD
@export var hud_path: NodePath
@onready var hud = get_node_or_null(hud_path) if hud_path else null

# Facing
var last_facing := 1   # 1 = right, -1 = left
var hp := 100
var max_hp := 100



var inventoryLimit = 2
var slot_left: String = ""
var slot_right: String = ""

var inventoryLimit = 2
var slot_left: String = ""
var slot_right: String = ""

# Store actual weapon objects
var slot_left_object = null
var slot_right_object = null
var current_weapon = null  # Currently equipped weapon
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

# =========================
# READY
# =========================
func _ready():
	add_to_group("player")
	
	# Auto-detect HUD if not manually set
	if not hud:
		hud = get_tree().get_first_node_in_group("hud")
	
	if hud:
		print("HUD connected successfully")
		hud.clear_slot("left")
		hud.clear_slot("right")
	else:
		push_warning("HUD not found! Please set hud_path or add HUD to 'hud' group")


# =========================
# MAIN LOOP
# =========================
func _physics_process(_delta):

	handle_movement()
	move_and_slide()
	checkEffect()
	cameraShake()
	handle_inventory_input()


# =========================
# MOVEMENT
# =========================
func handle_movement():
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

# =========================
# INVENTORY INPUT
# =========================
func handle_inventory_input():
	if Input.is_action_just_pressed("m1"):
		use_slot("left")
		
	if Input.is_action_just_pressed("m2"):
		use_slot("right")


# =========================
# INVENTORY CORE
# =========================
func add_item(item_name: String) -> bool:
	# Slot kiri dulu
	if slot_left == "":
		slot_left = item_name
		if hud:
			print("Setting LEFT slot to:", item_name)
			hud.set_slot("left", item_name)
		else:
			push_warning("HUD is null, cannot update icon")
		print("Item masuk slot LEFT:", item_name)
		return true

	# Slot kanan
	if slot_right == "":
		slot_right = item_name
		if hud:
			print("Setting RIGHT slot to:", item_name)
			hud.set_slot("right", item_name)
		else:
			push_warning("HUD is null, cannot update icon")
		print("Item masuk slot RIGHT:", item_name)
		return true

	# Inventory penuh
	print("Inventory penuh!")
	return false


# For weapons that need object reference
func add_item_object(item_name: String, item_object) -> bool:
	# Slot kiri dulu
	if slot_left == "":
		slot_left = item_name
		slot_left_object = item_object
		if hud:
			print("Setting LEFT slot to:", item_name)
			hud.set_slot("left", item_name)
		else:
			push_warning("HUD is null, cannot update icon")
		print("Item masuk slot LEFT:", item_name)
		return true

	# Slot kanan
	if slot_right == "":
		slot_right = item_name
		slot_right_object = item_object
		if hud:
			print("Setting RIGHT slot to:", item_name)
			hud.set_slot("right", item_name)
		else:
			push_warning("HUD is null, cannot update icon")
		print("Item masuk slot RIGHT:", item_name)
		return true

	# Inventory penuh
	print("Inventory penuh!")
	return false


func use_slot(side: String):
	var item := ""

	if side == "left":
		item = slot_left
	else:
		item = slot_right

	# Slot kosong → punch
	if item == "":
		start_punch()
		return

	use_item(item, side)


func use_item(item_name: String, side: String):
	print("Using:", item_name, "from", side)

	match item_name:
		"antidote":
			useAntidote()
			clear_slot(side)

		"flashlight":
			useFlashLight()
			clear_slot(side)

		"heal":
			use_heal()
			clear_slot(side)
		
		"knife", "gun":
			# Equip weapon
			equip_weapon(side)



func equip_weapon(side: String):
	var weapon_object = null
	
	if side == "left":
		weapon_object = slot_left_object
	else:
		weapon_object = slot_right_object
	
	if weapon_object == null:
		return
	
	# Unequip current weapon if any
	if current_weapon and current_weapon != weapon_object:
		if current_weapon.has_method("unequip"):
			current_weapon.unequip()
	
	# Equip new weapon
	if weapon_object.has_method("equip"):
		weapon_object.equip()
		current_weapon = weapon_object
		print("Weapon equipped from", side, "slot")

# Remove weapon from inventory when it's destroyed
func remove_weapon_from_inventory(weapon_object):
	if slot_left_object == weapon_object:
		print("Knife/Gun destroyed, clearing LEFT slot")
		clear_slot("left")
	elif slot_right_object == weapon_object:
		print("Knife/Gun destroyed, clearing RIGHT slot")
		clear_slot("right")

func clear_slot(side: String):
	# Unequip weapon if it's the current one
	var weapon_obj = slot_left_object if side == "left" else slot_right_object
	if weapon_obj and weapon_obj == current_weapon:
		if current_weapon.has_method("unequip"):
			current_weapon.unequip()
		current_weapon = null
	
	if side == "left":
		slot_left = ""
		slot_left_object = null
	else:
		slot_right = ""
		slot_right_object = null

	if hud:
		hud.clear_slot(side)


# =========================
# ITEM EFFECT
# =========================
func use_heal():
	hp += 20
	hp = min(hp, max_hp)
	print("Heal used, HP:", hp)


func useAntidote():
	if effect != "poison":
		return

	effect = ""
	isPoisonActive = false
		
	poison.poison_timer.stop()
	poison.poison_elapsed = 0
	modulate = Color(1,1,1,1)


func useFlashLight():
	flash_light.flashLightEffect()

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

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		isShake = true
		await get_tree().create_timer(shakeDuration).timeout
		isShake = false
	else:
		camera.offset = Vector2.ZERO

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


func start_punch():
	# Play punch animation or trigger punch attack
	print("Player punches!")
	# Add punch animation logic here
	# You can add a punch hitbox or animation trigger
	pass
