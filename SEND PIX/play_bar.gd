extends ColorRect

var progress_ratio :float = 0 :set = set_progress_ratio

@export var base_line_thickness :float = .2
@export var line_ratio :float = 3

var mouse_clicked :bool = false
var base_color_ratio :float = .6

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color

signal clicked(ratio:float)

func set_progress_ratio(val:float) :
	progress_ratio = val
	self.material.set_shader_parameter("progress",val)

func _ready():
	self.material.set_shader_parameter("progress",.0)
	self.material.set_shader_parameter("base_line_thickness",base_line_thickness)
	self.material.set_shader_parameter("line_ratio",line_ratio)
	self.material.set_shader_parameter("color_theme",theme_color)
	self.material.set_shader_parameter("color_ratio",base_color_ratio)

func _input(event): 
	if event is InputEventMouseButton :
		if event.button_index == MOUSE_BUTTON_LEFT :
			if event.is_pressed() and is_mouse_in_object(self) :
				mouse_clicked = true
				#set_color(1.)
				move_cursor_to_mouse_pos()
			if event.is_released() and mouse_clicked :
				mouse_clicked = false
				_on_mouse_exited()
	
	elif event is InputEventMouseMotion and mouse_clicked :
		move_cursor_to_mouse_pos()

func is_mouse_in_object(object) :
	return Rect2(Vector2(.0,.0), object.size).has_point(get_local_mouse_position())

func _on_mouse_entered():
	if !mouse_clicked :
		var tween = create_tween()
		tween.tween_method(set_color_ratio,base_color_ratio,1.,.2)


func _on_mouse_exited():
	if !mouse_clicked and !is_mouse_in_object(self):
		var tween = create_tween()
		tween.tween_method(set_color_ratio,1.,base_color_ratio,.2)

func set_color_ratio(value:float) :
	self.material.set_shader_parameter("color_ratio",value)

func move_cursor_to_mouse_pos() :
	var mouse_pos = get_local_mouse_position()
	print(mouse_pos)
	var ratio_pos = mouse_pos.x /self.size.x
	clicked.emit(ratio_pos)
	print(ratio_pos)
