extends CharacterBody2D
class_name Monster

# 移动参数
@export var pulse_distance = 50.0  # 每次脉冲移动的距离（像素）
@export var pulse_interval = 1.0  # 脉冲间隔（秒）
@export var pulse_speed = 200.0  # 脉冲移动速度（像素/秒）

# 引用
var game: Game
var _boat: Node = null

# 内部状态
var _is_moving = false  # 是否正在脉冲移动中
var _pulse_timer = 0.0  # 脉冲计时器
var _target_x = 0.0  # 本次脉冲的目标 x 坐标
var _is_in_attack_range = false  # 是否在攻击范围内

func _ready():
	# 连接攻击范围信号
	%attack_range.body_entered.connect(_on_attack_range_body_entered)
	%attack_range.body_exited.connect(_on_attack_range_body_exited)

func _process(delta):
	# 同步到水平线
	if game != null:
		position.y = game.water_level
	
	# 更新脉冲计时器
	if not _is_moving and not _is_in_attack_range:
		_pulse_timer += delta
		if _pulse_timer >= pulse_interval:
			_start_pulse()
			_pulse_timer = 0.0

func _physics_process(delta):
	# 执行脉冲移动
	if _is_moving:
		var direction = sign(_target_x - position.x)
		var distance_to_target = abs(_target_x - position.x)
		
		if distance_to_target > 1.0:
			# 继续移动
			velocity.x = direction * pulse_speed
			move_and_slide()
		else:
			# 到达目标，停止
			position.x = _target_x
			velocity.x = 0
			_is_moving = false
	else:
		velocity.x = 0

# 开始一次脉冲移动
func _start_pulse():
	_is_moving = true
	# 向船的方向移动
	if _boat != null:
		var direction = sign(_boat.global_position.x - global_position.x)
		_target_x = position.x + direction * pulse_distance
	else:
		# 如果没有找到船，向右移动
		_target_x = position.x + pulse_distance

# 攻击范围检测
func _on_attack_range_body_entered(body: Node2D):
	print("boat entered attack range")
	_is_in_attack_range = true
	_is_moving = false
	velocity.x = 0

func _on_attack_range_body_exited(body: Node2D):
	# 检查是否是船的 body
	if body.name == "body" and body.get_parent() is Boat:
		_is_in_attack_range = false
