extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_Play_pressed() -> void:
	#get_tree().change_scene_to_file() masukin direktori scenenya
	pass # Replace with function body.

func _on_Credit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/credit.tscn") 

func _on_Exit_pressed() -> void:
	get_tree().quit()

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn") 
