extends Node2D

var hp = 20
var damage = 5
var wearOut = 5 

var isOnPlayer = false
var isCollected = false  # Prevent duplication

@onready var body: Node2D = $body
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body.position = Vector2(0,0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isOnPlayer:
		look_at(get_global_mouse_position())
		checkOnPlayer()
		checkAngle()
		death()
	pass


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		hitEnemy(body)
		pass
	pass # Replace with function body.

func hitEnemy(body: Node2D):
	if not is_instance_valid(body):
		return

	body.hp -= damage
	hp -= wearOut

	body.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout

	if is_instance_valid(body):
		body.modulate = Color.WHITE
		
	
func checkOnPlayer():
	if isOnPlayer == true:
		global_position = player.global_position
		body.position = Vector2(25,0)

func checkAngle():
	if rotation > PI / 2 or rotation < -PI / 2:
		body.scale.y = -1
	else:
		body.scale.y = 1

func equip():
	print("Knife equipped!")
	isOnPlayer = true
	visible = true
	set_process(true)

func unequip():
	isOnPlayer = false
	visible = false
	set_process(false)

func _on_collect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not isCollected:
		# Simpan ke inventory tapi belum aktif
		var success = body.add_item_object("knife", self)
		if success:
			isCollected = true  # Mark as collected to prevent duplication
			# Hide knife, tunggu sampai di-equip
			visible = false
			set_process(false)
	pass # Replace with function body.

func death():
	if hp <= 0:
		# Clear inventory slot before destroying
		if player and is_instance_valid(player):
			player.remove_weapon_from_inventory(self)
		queue_free()
