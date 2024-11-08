extends Control

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color
@onready var color_scene = $VBoxContainer/Color_Palette
var selected_color :Color : get = get_selected_color

@onready var label_node = $VBoxContainer/Label

const label_size :float = .06
const label_color_factor :float = .6

@onready var pencil_node = $VBoxContainer/MarginContainer/tools/pencil
@onready var bucket_node = $VBoxContainer/MarginContainer/tools/bucket

var tools_array = []
var tool_frame_size :float = .01

var hovered :bool = false

signal tool_selected(tool_index)

func get_selected_color() :
	return color_scene.selected_color

func _ready():
	label_node.label_settings.font_color = theme_color
	_on_resized()
	pencil_node._on_button_mouse_entered()
	pencil_node._on_button_pressed()
	
	tools_array.append(pencil_node)
	tools_array.append(bucket_node)
	
	for i in range(len(tools_array)) :
		tools_array[i].tool_index = i
	
	pencil_node.base_color_factor = label_color_factor
	bucket_node.base_color_factor = label_color_factor
	
	pencil_node.material.set_shader_parameter("theme_color",theme_color)
	pencil_node.material.set_shader_parameter("line_thickness",tool_frame_size)
	pencil_node.material.set_shader_parameter("color_factor",label_color_factor)
	
	bucket_node.material.set_shader_parameter("theme_color",theme_color)
	bucket_node.material.set_shader_parameter("line_thickness",tool_frame_size)
	bucket_node.material.set_shader_parameter("color_factor",label_color_factor)
	bucket_node.material.set_shader_parameter("line_as_fill",true)

func _process(delta):
	if is_mouse_in_object(self) and !hovered :
		hovered = true
		var tween = create_tween()
		tween.tween_method(set_image_label_color_factor,.9,1.,.1)
	elif !is_mouse_in_object(self) and hovered :
		hovered = false
		var tween = create_tween()
		tween.tween_method(set_image_label_color_factor,1.,.9,.5)


func _on_resized():
	if color_scene != null :
		label_node.label_settings.font_size = self.size.y * label_size
		color_scene.label_node.label_settings.font_size = self.size.y * label_size
		pencil_node.parent_size = self.size.x
		bucket_node.parent_size = self.size.x
		pencil_node.update_size()
		bucket_node.update_size()

func is_mouse_in_object(object) :
	return Rect2(object.position, object.size+Vector2(.0,1000)).has_point(get_local_mouse_position())
	
func set_image_label_color_factor(factor :float) :
	label_node.label_settings.font_color = theme_color * factor


func _on_tool_selected(tool_index):
	tool_selected.emit(tool_index)
	for i in range(len(tools_array)) :
		if i!= tool_index :
			tools_array[i].unselect()
