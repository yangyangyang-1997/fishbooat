extends Node
class_name Game

@onready var camera = %camera

@export var water_level = -100.0
@export var camera_shake_strength = 5.0  # 开火时相机抖动强度

# 怪物生成参数
@export var monster_spawn_interval = 5.0  # 怪物生成间隔（秒）
@export var monster_spawn_distance = 600.0  # 生成距离（船两侧的距离）
var _monster_scene = preload("res://monsters/monster.tscn")
var _spawn_timer = 0.0

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

func _process(delta):
	# 更新怪物生成计时器
	_spawn_timer += delta
	if _spawn_timer >= monster_spawn_interval:
		_spawn_monster()
		_spawn_timer = 0.0

# 设置所有怪物的 game 引用
func _setup_monsters():
	for child in get_children():
		if child is Monster:
			child.game = self

# 生成怪物
func _spawn_monster():
	var monster = _monster_scene.instantiate()
	add_child(monster)
	
	# 设置 game 引用
	monster.game = self
	
	# 随机选择左侧或右侧生成
	var spawn_on_left = randf() > 0.5
	var boat_x = %boat.global_position.x
	
	if spawn_on_left:
		# 左侧生成，向右移动
		monster.global_position.x = boat_x - monster_spawn_distance
		monster.set_direction(Monster.Direction.RIGHT)
	else:
		# 右侧生成，向左移动
		monster.global_position.x = boat_x + monster_spawn_distance
		monster.set_direction(Monster.Direction.LEFT)
	
	# 设置 y 坐标到水平线
	monster.global_position.y = water_level

func _unhandled_input(event):
	if event is InputEventKey and event.is_released():
		if event.keycode == KEY_A:
			%boat.apply_impact_vector(Vector2(-1, 1))
		elif event.keycode == KEY_D:
			%boat.apply_impact_vector(Vector2(1, 1))
