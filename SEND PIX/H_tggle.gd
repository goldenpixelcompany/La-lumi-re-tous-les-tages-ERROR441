extends TextureButton


var toggled_ :bool = false

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color

signal toggled_state_change(val :bool)

func _ready():
	self.material.set_shader_parameter('theme_color',theme_color)
	self.material.set_shader_parameter('border_size', .1)
	self.custom_minimum_size = Vector2(50,50)

func _process(delta):
	pass


func _on_pressed():
	print('pressed')
	toggled_ = !toggled_
	toggled_state_change.emit(toggled_)
	self.material.set_shader_parameter("on",toggled_)
