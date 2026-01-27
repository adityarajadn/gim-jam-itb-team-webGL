extends Area2D

@export var speed := 500
@export var max_distance := 500
@export var collision_delay := 0.08

var direction: Vector2 = Vector2.ZERO
var start_pos: Vector2
var stuck := false
var can_hit := false

@onready var sprite: AnimatedSprite2D = $animasiKapak
@onready var collision: CollisionShape2D = $CollisionShape2D


func init(dir: Vector2) -> void:
	direction = dir.normalized()


func _ready() -> void:
	start_pos = global_position
	sprite.play("Throw")

	monitoring = true
	monitorable = true

	# cegah self-hit
	collision.disabled = true
	can_hit = false

	await get_tree().create_timer(collision_delay).timeout

	collision.disabled = false
	can_hit = true


func _physics_process(delta: float) -> void:
	if stuck:
		return

	global_position += direction * speed * delta

	if global_position.distance_to(start_pos) >= max_distance:
		stick_to_ground()


@onready var player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body: Node) -> void:
	if stuck or not can_hit:
		return

	if body == player:
		queue_free()
		return

	if body.is_in_group("Environment"):
		stick_to_ground()


func stick_to_ground() -> void:
	stuck = true
	can_hit = false
	collision.disabled = true

	sprite.play("Landing")
	await sprite.animation_finished
	queue_free()
