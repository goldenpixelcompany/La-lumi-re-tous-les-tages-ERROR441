extends Control

@onready var label_node = $MarginContainer/Label
@onready var colorect_node = $MarginContainer/ColorRect
@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color
@onready var margin_node = $MarginContainer
@onready var textedit_node = $MarginContainer/TextEdit

var name_edit :bool = false

var aspect_ratio :float : set = set_aspect_ratio
var line_thickness :float :set = set_line_thickness
var color_ratio :float = .8

var base_line_thickness :float = .02
var hovered_line_thickness :float = .03

var font_size :float = 1./8.

var margin_factor :float = .05
var margin_factor_hovered :float = margin_factor*1.2
var margin_value :int : set = set_margin

signal export(user_name :String)

func set_aspect_ratio (value :float) :
	aspect_ratio = value
	colorect_node.material.set_shader_parameter("aspect_ratio",value)

func set_line_thickness (value :float) :
	line_thickness = value
	colorect_node.material.set_shader_parameter("line_thinckness",value)

func _ready():
	_on_resized()
	colorect_node.material.set_shader_parameter("theme_color",theme_color*color_ratio)
	label_node.label_settings.font_color = theme_color*color_ratio
	line_thickness = base_line_thickness
	
	textedit_node.add_theme_color_override("caret_color",theme_color)
	textedit_node.add_theme_color_override("font_color",theme_color)
	textedit_node.add_theme_color_override("font_placeholder_color",theme_color*color_ratio)
	
	#Suppression du scrolling du text prompt 
	for child in textedit_node.get_children():
		if child is VScrollBar:
			textedit_node.remove_child(child)
		elif child is HScrollBar:
			textedit_node.remove_child(child) 

func _input(event) :
	if event.is_action_pressed("ui_text_submit") and name_edit :
		export.emit(textedit_node.text)
		congrats_animation()

func _on_resized():
	await get_tree().create_timer(0.2).timeout
	aspect_ratio = self.size.x /self.size.y
	label_node.label_settings.font_size = self.size.x*font_size
	
	margin_value = self.size.y/margin_factor
	_on_button_mouse_exited()
	
	textedit_node.add_theme_font_size_override("font_size",self.size.x*font_size)
	textedit_node.custom_minimum_size = Vector2(len(textedit_node.text)*self.size.x*font_size*aspect_ratio,self.size.x*font_size)
	textedit_node.max_length = 13

func _on_button_mouse_entered():
	#label_node.label_settings.font_size = self.size.x*(font_size*1.2)
	if !name_edit :
		label_node.label_settings.font_color = theme_color
		
		colorect_node.material.set_shader_parameter("theme_color",theme_color)
		line_thickness = hovered_line_thickness
		
		var tween = create_tween()
		tween.tween_method(set_margin,self.size.y*margin_factor, self.size.y*margin_factor_hovered,.1)
		tween.parallel().tween_property(label_node.label_settings,"font_size",self.size.x*(font_size*1.1),.1)

func _on_button_mouse_exited():
	#label_node.label_settings.font_size = self.size.x*(font_size)
	if !name_edit :
		label_node.label_settings.font_color = theme_color * color_ratio
		
		line_thickness = base_line_thickness
		colorect_node.material.set_shader_parameter("theme_color",theme_color*color_ratio)
		
		var tween = create_tween()
		tween.tween_method(set_margin,self.size.y*margin_factor_hovered, self.size.y*margin_factor,.1)
		tween.parallel().tween_property(label_node.label_settings,"font_size",self.size.x*(font_size),.1)

func set_margin(value :int) :
	margin_node.add_theme_constant_override("margin_top",value)
	#margin_node.add_theme_constant_override("margin_bottom",value)
	
	margin_node.add_theme_constant_override("margin_left",value*aspect_ratio)
	margin_node.add_theme_constant_override("margin_right",value*aspect_ratio)


func _on_button_pressed():
	if !name_edit :
		textedit_node.text = ''
		var tween = create_tween()
		tween.tween_method(set_margin,self.size.y*margin_factor_hovered, self.size.y*margin_factor/5.0,.1)
		label_node.hide()
		textedit_node.show()
		name_edit = true
		textedit_node.custom_minimum_size = Vector2(self.size.x*.9,self.size.x*font_size*1.5)
		textedit_node.grab_focus()
		print("FOCUS ? : ",textedit_node.has_focus())
		DisplayServer.virtual_keyboard_show("")
		var is_supported = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)
		print(is_supported)

func _on_text_edit_text_changed(new_text :String):
	textedit_node.text = new_text.to_upper()
	textedit_node.caret_column = len(textedit_node.text)

func congrats_animation() :
	textedit_node.hide()
	label_node.text = "MERCI !"
	label_node.show()
	await get_tree().create_timer(2).timeout
	name_edit = false
	label_node.text = 'SEND PIXS'
	
	_on_button_mouse_exited()
