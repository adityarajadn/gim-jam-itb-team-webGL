extends CharacterBody2D

var damage = 10;
var bulletDirection;

var pos: Vector2
var rot: float
var dir: float
var speed = 2000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = pos
	global_rotation = rot
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	pass

func _on_hit_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		hitEnemy(body)
	pass # Replace with function body.

func hitEnemy(body: Node2D) -> void:
	body.hp -= damage
	destroyObject()
	
func destroyObject():
	queue_free()

func _on_timer_timeout() -> void:
	destroyObject()
	pass # Replace with function body.
