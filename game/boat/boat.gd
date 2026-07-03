extends Node2D
class_name Boat

# 浮动参数
var float_amplitude = 8.0  # 上下浮动幅度（像素）
var float_speed = 1.5  # 浮动速度
var float_time = 0.0  # 浮动时间累积
var float_velocity = 0.0  # 垂直浮动速度（受冲击影响）
var float_damping = 1.0  # 垂直浮动阻尼

# 倾斜/晃动参数
var tilt_angle = 0.0  # 当前倾斜角度（弧度）
var tilt_velocity = 0.0  # 倾斜角速度
var tilt_spring_strength = 5.0  # 弹簧恢复力（类似浮力的恢复力矩）
var tilt_damping = 0.6  # 阻尼系数（模拟水的阻力）
var max_tilt = deg_to_rad(50.0)  # 最大倾斜角度

# 海浪参数
var wave_timer = 0.0
var wave_interval_min = 3.0  # 最小海浪间隔
var wave_interval_max = 8.0  # 最大海浪间隔
var next_wave_time = 5.0  # 下次海浪时间
var wave_strength = 0.5  # 海浪冲击强度

# 水平面高度（临时方案，相对于船的初始位置）
var water_level = 0.0
var base_position = Vector2.ZERO

func _ready():
	# 记录初始位置作为基准点
	base_position = position
	# 随机化第一次海浪时间
	randomize()
	next_wave_time = randf_range(wave_interval_min, wave_interval_max)

func _process(delta):
	# 更新浮动时间
	float_time += delta * float_speed
	# 计算基础上下浮动
	var float_offset = sin(float_time) * float_amplitude
	# 更新垂直浮动速度（受冲击影响，带阻尼衰减）
	float_velocity -= float_velocity * float_damping * delta
	float_offset += float_velocity * delta * 60.0  # 乘以60是为了让效果更明显
	# 应用浮动到Y轴位置
	position.y = base_position.y + float_offset
	# 海浪系统
	wave_timer += delta
	if wave_timer >= next_wave_time:
		_apply_wave()
		wave_timer = 0.0
		next_wave_time = randf_range(wave_interval_min, wave_interval_max)

	# 更新倾斜角度（阻尼弹簧模型）
	# 恢复力：-spring * angle（类似浮力产生的恢复力矩）
	# 阻尼力：-damping * velocity（类似水的阻力）
	var restore_force = -tilt_angle * tilt_spring_strength
	var damping_force = -tilt_velocity * tilt_damping
	var tilt_acceleration = restore_force + damping_force
	
	tilt_velocity += tilt_acceleration * delta
	tilt_angle += tilt_velocity * delta
	
	# 限制最大倾斜角度
	tilt_angle = clamp(tilt_angle, -max_tilt, max_tilt)
	
	# 应用倾斜
	rotation = tilt_angle

# 海浪冲击（内部使用）
func _apply_wave():
	var wave_direction = randf_range(-1.0, 1.0)
	apply_impact(wave_direction * wave_strength)

# 公开API：施加冲击
# strength: 冲击强度，正值向右倾斜，负值向左倾斜
func apply_impact(strength):
	tilt_velocity += strength

# 公开API：施加冲击（向量版本）
# force: 二维力向量，x分量影响倾斜，y分量影响垂直浮动
func apply_impact_vector(force):
	# x分量影响倾斜
	apply_impact(force.x)
	# y分量影响垂直浮动
	# 正值向下推，负值向上推
	float_velocity += force.y  # 缩放因子可调整

# 公开API：重置船的状态
func reset_boat():
	tilt_angle = 0.0
	tilt_velocity = 0.0
	float_velocity = 0.0
	rotation = 0.0
	position = base_position
