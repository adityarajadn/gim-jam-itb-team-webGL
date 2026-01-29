extends Node

# =========================
# CONFIG WAVE
# =========================
@export var spawner: Node
@export var prep_time := 7.0
@export var wave_time := 60.0
@export var countdown: Label
@export var wave_text: Label

# =========================
# CONFIG RULE
# =========================
@export var must_move_damage := 1
@export var must_move_threshold := 1.0
@export var must_move_check_interval := 1.0

var must_move_timer := 0.0

# =========================
# RULE ENUM
# =========================
enum WaveRule {
	DONT_FIGHT,
	NO_HEAL,
	MUST_MOVE,
	REDUCE_INVENTORY
}

var current_rule: WaveRule
var previous_rule := -1

# =========================
# INTERNAL STATE
# =========================
var timer := 0.0
var current_wave := 0
var in_prep := true
var last_player_pos := Vector2.ZERO


# =========================
# REFERENCES
# =========================
@onready var player := get_tree().get_first_node_in_group("player")

# =========================
# READY
# =========================
func _ready():
	if player == null:
		push_error("WaveManager: Player not found (group 'player')")
		return

# =========================
# CORE LOOP
# =========================
func _process(delta):
	timer += delta

	if in_prep and timer >= prep_time:
		start_wave()

	elif not in_prep and timer >= wave_time:
		end_wave()

	_update_ui()

	# MUST MOVE rule tick
	if not in_prep and current_rule == WaveRule.MUST_MOVE:
		must_move_timer += delta
		if must_move_timer >= must_move_check_interval:
			_check_must_move()
			must_move_timer = 0.0

# =========================
# WAVE FLOW
# =========================
func start_wave():
	timer = 0
	in_prep = false
	current_wave += 1

	# Spawner scaling
	if spawner:
		spawner.spawn_interval = max(0.3, 0.6 - current_wave * 0.05)

	_pick_rule()
	_apply_rule(current_rule)

	print("=== WAVE", current_wave, "RULE:", WaveRule.keys()[current_rule], "===")

func end_wave():
	timer = 0
	in_prep = true
	_clear_rule()
	clear_all_enemies()

# =========================
# RULE SELECTION
# =========================
func _pick_rule():
	var rules = WaveRule.values()
	if previous_rule != -1:
		rules.erase(previous_rule)

	current_rule = rules.pick_random()
	previous_rule = current_rule

# =========================
# APPLY RULE
# =========================
func _apply_rule(rule: WaveRule):
	match rule:
		WaveRule.DONT_FIGHT:
			for child in player.get_children():
				if child.has_method("unequip"):
					child.unequip()
					child.set_process(false)

		WaveRule.NO_HEAL:
			if player.slot_left == "heal":
				player.clear_slot("left")
			if player.slot_right == "heal":
				player.clear_slot("right")

		WaveRule.MUST_MOVE:
			last_player_pos = player.global_position
			must_move_timer = 0.0

		WaveRule.REDUCE_INVENTORY:
			if player.slot_right != "":
				player.clear_slot("right")

# =========================
# CLEAR RULE
# =========================
func _clear_rule():
	for child in player.get_children():
		if child.has_method("equip"):
			child.set_process(true)

# =========================
# MUST MOVE CHECK
# =========================
func _check_must_move():
	if player.global_position.distance_to(last_player_pos) < must_move_threshold:
		if player.has_method("takeDamage"):
			player.takeDamage(must_move_damage)

	last_player_pos = player.global_position

# =========================
# ENEMY CLEANUP
# =========================
func clear_all_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.queue_free()

# =========================
# UI
# =========================
func _update_ui():
	if in_prep:
		countdown.text = "%d" % int(prep_time - timer)
	else:
		countdown.text = "%d" % int(wave_time - timer)

	wave_text.text = "Wave : %d" % current_wave
