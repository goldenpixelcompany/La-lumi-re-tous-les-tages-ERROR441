extends TextureRect

var base_color_factor :float = .7

var tool_index :int = 0

var parent_size :float 
var marge_size :float 
var marge_ratio :float = .025

var selected_size_ratio :float = 1.1

var clicked :bool = false

signal selected (tool_index :int)

func _ready():
	
	marge_size = parent_size *marge_ratio
	print(parent_size)

func _process(delta):
	pass


func _on_button_mouse_entered():
	if !clicked :
		self.material.set_shader_parameter("hovered",true)
		set_color_factor(1.)


func _on_button_mouse_exited():
	if !clicked :
		self.material.set_shader_parameter("hovered",false)
		set_color_factor(base_color_factor)

func set_color_factor(value :float) :
	self.material.set_shader_parameter("color_factor",value)


func _on_button_pressed():
	print(tool_index, " clicked")
	if !clicked :
		selected.emit(tool_index)
		var tween = create_tween()
		tween.tween_method(set_custom_size,self.size,self.size*selected_size_ratio,.07)
		clicked = true
		

func set_custom_size(new_size :Vector2) :
	var new_position :Vector2 = (self.size - new_size) *.5
	self.position += new_position
	self.size = new_size

func unselect() :
	clicked = false
	var tween = create_tween()
	tween.tween_property(self,"size",Vector2(1.,1.) * self.size/selected_size_ratio,.07)
	print(parent_size)
	tween.parallel().tween_property(self,"position",Vector2((self.size.x + marge_size)* tool_index ,.0),.07)

	self.material.set_shader_parameter("hovered",false)
	self.material.set_shader_parameter("color_factor",base_color_factor)

func update_size() :
	marge_size = parent_size *marge_ratio
	print('marge_size',marge_size)
