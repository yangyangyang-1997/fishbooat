extends Node
class_name Game

@onready var camera := %camera

@export var water_level := -100.0

func _enter_tree():
	%boat.game = self

func _unhandled_input(event):
	if event is InputEventKey and event.is_released():
		if event.keycode == KEY_A:
			%boat.apply_impact_vector(Vector2(-1, 1))
		elif event.keycode == KEY_D:
			%boat.apply_impact_vector(Vector2(1, 1))
