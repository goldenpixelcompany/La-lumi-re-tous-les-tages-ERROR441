extends Control

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color
@onready var color_node = $Label/ColorRect
@onready var label_node = $Label

var selected :bool = false : set = select
var single_click : bool  = false

var label_font_size :float = .05
var color_factor :float = .8

var dir_path :String :set = set_dir_path

var index :int = 0

signal selection_confirmed(dir_path :String)
signal slot_selected(index :int)

func set_dir_path(new_path :String) :
	dir_path = new_path
	label_node.text = new_path.split("/")[-1].to_upper()
	self.custom_minimum_size = label_node.size

func select(val :bool) :
	if val :
		selected = true
		self.grab_focus()
	else :
		selected = false
		single_click = false
		_on_button_mouse_exited()
		

func _ready():
	label_node.label_settings.font_color = theme_color*color_factor
	color_node.color = Color.BLACK
	
	
	_on_resized()

func _process(delta):
	pass


func _on_button_mouse_entered():
	if !selected :
		color_node.color = theme_color * color_factor
		label_node.label_settings.font_color = Color.BLACK
	else :
		color_node.color = theme_color

func _on_button_mouse_exited():
	if !selected :
		color_node.color = Color.BLACK
		label_node.label_settings.font_color = theme_color*color_factor
	else :
		color_node.color = theme_color*color_factor


func _on_button_pressed():
	if single_click :
		print('double_click')
		selection_confirmed.emit(dir_path)
	else :
		single_click = true
		selected = true
		color_node.color = theme_color
		$Timer.start()
		slot_selected.emit(index)


func _on_timer_timeout():
	single_click = false


func _on_resized():
	if label_node != null :
		label_node.label_settings.font_size = self.size.x * label_font_size


func _on_label_minimum_size_changed():
	self.custom_minimum_size = label_node.size

func confirm() :
	selection_confirmed.emit(dir_path)
