extends Node
class_name Game

@onready var camera := %camera

@export var water_level := -100.0
@export var camera_shake_strength = 5.0  # 开火时相机抖动强度

func _enter_tree():
	%boat.game = self

func _ready():
	# 设置所有怪物的 game 引用
	_setup_monsters()
	
	# 连接船的 bullet_fire 信号到相机抖动
	%boat.bullet_fire.connect(func(_fire_direction):
		#camera.shake(camera_shake_strength)
		camera.shake_ex(camera_shake_strength, 0.4, 6.0)
	)

# 设置所有怪物的 game 引用
func _setup_monsters():
	for child in get_children():
		if child is Monster:
			child.game = self

func _unhandled_input(event):
	if event is InputEventKey and event.is_released():
		if event.keycode == KEY_A:
			%boat.apply_impact_vector(Vector2(-1, 1))
		elif event.keycode == KEY_D:
			%boat.apply_impact_vector(Vector2(1, 1))
