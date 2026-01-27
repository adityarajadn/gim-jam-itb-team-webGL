extends Area2D

@export var speed := 500
@export var max_distance := 400
@export var collision_delay := 0.08

var direction: Vector2
var start_pos: Vector2
var stuck := false
var can_hit := false
var target: Node2D   # <-- injected dependency

@onready var sprite: AnimatedSprite2D = $animasiKapak
@onready var collision: CollisionShape2D = $CollisionShape2D


func init(dir: Vector2, target_ref: Node2D) -> void:
	direction = dir.normalized()
	target = target_ref
	start_pos = global_position


func _ready() -> void:
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


func _on_body_entered(body: Node) -> void:
	if stuck or not can_hit:
		return

	if body == target:
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
