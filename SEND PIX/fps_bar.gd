extends Control

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color
@onready var line_node = $Line
@onready var label_node = $label_bg/Label
@onready var label_bg_node = $label_bg

var line_size :float = .04
var font_size :float = .6

var FPS_value :float : set = set_FPS_value
var max_FPS :float = 25

var step :float 

var label_bg_size_factor :float = 2.

signal value_change(value:float)

func set_FPS_value (value : float) :
	FPS_value = snappedf(value,step)
	label_node.text = str(FPS_value)
	value_change.emit(FPS_value)
	#print("txt set : ",label_node.text)
	#print("label_node_size : ", label_node.size.x)
	label_bg_node.position.x = FPS_value/max_FPS * (self.size.x-label_bg_node.size.x) 

func _ready():
	label_node.label_settings.font_color = theme_color 
	line_node.color = theme_color
	line_node.position.x = 0
	
	#print(label_node.label_settings.font_color)
	
	_on_resized()


func _on_resized():
	if label_node != null :
		#print("font_resized")
		line_node.custom_minimum_size = Vector2(self.size.x, self.size.y*line_size)
		line_node.size = line_node.custom_minimum_size
		line_node.position.y = .5*self.size.y - .5*line_node.size.y
		label_node.label_settings.font_size = min(self.size.x,self.size.y)*font_size
		await get_tree().create_timer(0.1).timeout
		#print(label_node.size.x)
		label_bg_node.custom_minimum_size.x =label_node.size.x * label_bg_size_factor
		label_bg_node.custom_minimum_size.y = self.size.y
		label_bg_node.size = label_bg_node.custom_minimum_size
		label_bg_node.position.x = FPS_value/max_FPS * (self.size.x-label_bg_node.size.x) 
		label_bg_node.position.y = .5*self.size.y - label_bg_node.size.y*.5
		#print(label_bg_node.size.x)


func set_color(color:Color) :
	label_node.label_settings.font_color = color 
	line_node.color = color

func is_mouse_in_object(object) :
	return Rect2(object.position, object.size).has_point(get_local_mouse_position())
