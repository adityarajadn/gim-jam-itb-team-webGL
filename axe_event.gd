extends Area2D

@export var speed := 300
@export var max_distance := 200

var direction := Vector2.ZERO
var start_pos := Vector2.ZERO
var stuck := false

@onready var anim :=$"../animasiKapak"
@onready var col := $CollisionShape2D


func _ready():
	start_pos = global_position
	anim.play("Throw")


func _physics_process(delta):
	if stuck:
		return

	global_position += direction * speed * delta

	if global_position.distance_to(start_pos) >= max_distance:
		stick()


func stick():
	if stuck:
		return

	stuck = true
	col.disabled = true
	anim.play("Landing")
	await anim.animation_finished
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("Player"):
		queue_free()
