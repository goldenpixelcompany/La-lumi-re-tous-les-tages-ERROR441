extends Control

@export var index :int 
@export var play :bool
@export var forth :bool
@export var margin :Vector2 
@export var line_thickness :float = .1

@export var base_color_ratio :float = .6


signal pressed(index : int)

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color



func _ready():
	self.material.set_shader_parameter("color_theme",theme_color)
	self.material.set_shader_parameter("play",play)
	self.material.set_shader_parameter("forth",forth)
	self.material.set_shader_parameter("marge",margin)
	print(margin)
	self.material.set_shader_parameter("line_thickness",line_thickness)
	set_color_ratio(base_color_ratio)


func _process(delta):
	pass


func _on_button_pressed():
	pressed.emit(index)


func _on_button_mouse_entered():
	create_tween().tween_method(set_color_ratio,base_color_ratio,1.,.07)


func _on_button_mouse_exited():
	create_tween().tween_method(set_color_ratio,1.,base_color_ratio,.07)

func set_color_ratio(value:float) :
	self.material.set_shader_parameter("color_factor",value)
