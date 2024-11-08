extends Control

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color
@onready var FPS_label = $HBoxContainer/FPS
@onready var FPS_bar_node = $HBoxContainer/FPS_bar_only
@onready var button_node = $HBoxContainer/FPS_bar_only/Button

var color_factor :float = .8
@export var label_size :float = .7
var FPS_value :float : set = set_FPS_value, get = get_FPS_value

var mouse_clicked :bool = false
var input_set :bool = true
var tween_playing :bool = false

@export var Label_text :String = 'IPS'
@export var max_value :float = 25.
@export var step :float = .1
@export var label_bg_size_factor :float = 2.

signal value_change(propriete :String, value :float)

func get_FPS_value() :
	return FPS_bar_node.FPS_value

func set_FPS_value (value :float) :
	if input_set :
		FPS_bar_node.FPS_value = value
		if !(mouse_clicked or tween_playing):

			var tween = create_tween()
			tween.tween_method(set_color,1.,color_factor,.35)

func _ready():
	set_color(color_factor)
	_on_resized()
	FPS_label.text = Label_text
	FPS_bar_node.max_FPS = max_value
	FPS_bar_node.step = step
	FPS_bar_node.label_bg_size_factor = label_bg_size_factor

func _input(event):
	if input_set :
		if event is InputEventMouseButton :
			if event.button_index == MOUSE_BUTTON_LEFT :
				if event.is_pressed() and is_mouse_in_object(FPS_bar_node) :
					mouse_clicked = true
					set_color(1.)
					move_cursor_to_mouse_pos()
				if event.is_released() and mouse_clicked :
					mouse_clicked = false
					_on_button_mouse_exited()
		
		elif event is InputEventMouseMotion and mouse_clicked :
			move_cursor_to_mouse_pos()
		

func _on_resized():
	if FPS_label != null :
		FPS_label.label_settings.font_size = min(self.size.y,self.size.x)*label_size

func set_color(_color_factor :float) :
	FPS_label.label_settings.font_color = theme_color*_color_factor
	FPS_bar_node.set_color(theme_color*_color_factor)

func set_step(value :float) :
	FPS_bar_node.step = value

func is_mouse_in_object(object) :
	return Rect2(object.position, object.size).has_point(get_local_mouse_position())

func _on_button_mouse_entered():
	if input_set :
		set_color(1.)


func _on_button_mouse_exited():
	if !mouse_clicked and !is_mouse_in_object(FPS_bar_node) :
		set_color(color_factor)


func _on_button_pressed():
	pass

func move_cursor_to_mouse_pos() :
	var mouse_pos = get_local_mouse_position() - FPS_bar_node.position
	var targetFPS_value = clamp(mouse_pos.x,.0,FPS_bar_node.size.x)/FPS_bar_node.size.x * FPS_bar_node.max_FPS
	var tween = create_tween()
	tween_playing = true
	tween.tween_property(self,'FPS_value',targetFPS_value,.2)
	tween.tween_callback(tween_playing_false)
	#FPS_value = clamp(mouse_pos.x,.0,FPS_bar_node.size.x)/FPS_bar_node.size.x * FPS_bar_node.max_FPS

func tween_playing_false() :
	tween_playing = false


func _on_fps_bar_only_value_change(value):
	value_change.emit(Label_text,value)
