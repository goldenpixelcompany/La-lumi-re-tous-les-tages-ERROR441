extends Control

signal tl_input(tl_change,is_playing)
var play :bool  = false :set = set_play

func set_play (value :bool):
	play = value
	$"/root/MouseCursorLogic".is_playing = value 
	play_node.material.set_shader_parameter("forward",!value)

@onready var back_node = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/back
@onready var play_node = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/play
@onready var forward_node = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/forward
@onready var FPS_bar_node = $MarginContainer/VBoxContainer/MarginContainer/FPS_bar

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color

var line_thickness :float = 0.025

var FPS :float :set = set_FPS , get = get_FPS  ##Frame rate (ips) 

func set_FPS(value) :
	FPS = value
	FPS_bar_node.FPS_value = value
	#frame_time = 1.0/FPS

func get_FPS() :
	if FPS_bar_node != null :
		return FPS_bar_node.FPS_value
	else :
		return 12.5

var step :float = .1
var frame_time :float = 1.0/FPS : get = get_frame_time

func get_frame_time() :
	return 1./FPS

var delta_buff = 0

func _ready():
	#print(frame_time)
	back_node.material.set_shader_parameter("line_thickness",line_thickness)
	back_node.material.set_shader_parameter("line_color",theme_color)
	back_node.material.set_shader_parameter("doubled",true)
	
	forward_node.material.set_shader_parameter("margin_size",Vector2(.15,.2))
	forward_node.material.set_shader_parameter("forward",true)
	forward_node.material.set_shader_parameter("line_thickness",line_thickness)
	forward_node.material.set_shader_parameter("scndTriangle_translation_coef", .666)
	forward_node.material.set_shader_parameter("line_color",theme_color)
	forward_node.material.set_shader_parameter("doubled",true)

	
	play_node.material.set_shader_parameter("margin_size",Vector2(.15,.2))
	play_node.material.set_shader_parameter("forward",true)
	play_node.material.set_shader_parameter("line_thickness",line_thickness)
	play_node.material.set_shader_parameter("line_color",theme_color)
	play_node.material.set_shader_parameter("scndTriangle_translation_coef", .333)
	play_node.material.set_shader_parameter("stop",true)
	play_node.material.set_shader_parameter("stop_margin",Vector2(2.5,1.3))
	
	await get_tree().create_timer(0.1).timeout
	FPS_bar_node.FPS_value = 12.5
	FPS_bar_node.set_step(step)



func _process(delta):
	if play :
		delta_buff += delta
	
		if delta_buff>frame_time :
			#print(delta_buff)
			delta_buff = 0 
			_on_forward_pressed()

func _input(event):
	if event.is_action_pressed("speed_up",true) :
		FPS = clamp(FPS+step,.0,25.)
	elif event.is_action_pressed("speed_down",true) :
		FPS = clamp(FPS-step,.0,25.)

func _on_back_pressed():
	self.tl_input.emit(-1,play)



func _on_play_pressed():
	play = !play



func _on_forward_pressed():
	self.tl_input.emit(+1,play)
