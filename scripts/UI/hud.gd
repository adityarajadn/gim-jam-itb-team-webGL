extends CanvasLayer

@export var icon_antidote: Texture2D
@export var icon_flashlight: Texture2D
@export var icon_gun: Texture2D
@export var icon_knife: Texture2D
@export var icon_heal: Texture2D

@onready var slot_left_icon: TextureRect = $LeftIcon
@onready var slot_right_icon: TextureRect = $RightIcon

var icons := {}

func _ready():
	add_to_group("hud")
	icons = {
		"antidote": icon_antidote,
		"flashlight": icon_flashlight,
		"gun": icon_gun,
		"knife": icon_knife,
		"heal": icon_heal,
	}
	
	clear_slot("left")
	clear_slot("right")


func set_slot(side: String, item_id: String):
	var tex = icons.get(item_id)
	if tex == null:
		push_warning("Icon not found for item: " + item_id)
		return
	
	print("HUD: Setting", side, "slot icon to", item_id)
	if side == "left":
		slot_left_icon.texture = tex
		slot_left_icon.visible = true
		print("Left icon updated, visible:", slot_left_icon.visible)
	else:
		slot_right_icon.texture = tex
		slot_right_icon.visible = true
		print("Right icon updated, visible:", slot_right_icon.visible)


func clear_slot(side: String):
	if side == "left":
		slot_left_icon.texture = null
		slot_left_icon.visible = false
	else:
		slot_right_icon.texture = null
		slot_right_icon.visible = false
