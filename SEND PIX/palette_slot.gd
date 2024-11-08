extends Control

var index :int
var color : Color :set = set_color ##Coordonnées polaires du curseur correspondant à la couleur du slot
var cursor_pos :Vector2 
var self_size :Vector2 : set = set_self_size ##Taille du color slot, définie par la taille de son grid_container parent

func set_self_size(value :Vector2) :
	self_size = value
	self.custom_minimum_size = value
	self.size = value

var pos_sum :Vector2 = Vector2(.0,.0) ##Variable de correction de la position (auto, ne doit pas être modifiée)

@export var base_frame_size : float = .035 ##Taille du cadre au repos
@export var selected_frame_size :float = 0.1 ##Taille du cadre quand le slot est selectionné
@export var color_factor :float = .6 ## Couleur du cadre (theme_color * color_factor) au repos
@export var none_margin :float = 0

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color
@onready var color_rect = $color

var selected :bool = false
var tweening :bool = false

signal slot_selected (color :Color, index:int)

func set_color(new_color : Color) :
	$color.color = new_color
	color = new_color 


func _ready():
	color_rect.material.set_shader_parameter("line_thickness",base_frame_size)
	color_rect.material.set_shader_parameter("color_factor",color_factor)
	color_rect.material.set_shader_parameter("line_color",theme_color)
	color_rect.material.set_shader_parameter("none",(index > 0))
	color_rect.material.set_shader_parameter("none_margin",none_margin)
	
	color = Color.BLACK
	cursor_pos = Vector2(.0,.0)
	self_size = self.size


func _on_button_mouse_entered():
	if !selected :
		color_rect.material.set_shader_parameter("line_thickness",base_frame_size*1.2)
		color_rect.material.set_shader_parameter("color_factor",1.)


func _on_button_mouse_exited():
	if !selected :
		color_rect.material.set_shader_parameter("line_thickness",base_frame_size)
		color_rect.material.set_shader_parameter("color_factor",color_factor)


func _on_button_pressed():
	if !selected :
		selected = true
		slot_selected.emit(color,index)
		color_rect.material.set_shader_parameter("line_thickness",selected_frame_size)
		color_rect.material.set_shader_parameter("color_factor",1.)
		color_rect.material.set_shader_parameter("none",false)
		
		var tween = create_tween()
		tween.tween_method(set_custom_size, self_size,self_size*1.1,.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

func unselect() :
	selected = false
	color_rect.material.set_shader_parameter("line_thickness",base_frame_size)
	color_rect.material.set_shader_parameter("color_factor",color_factor)
	
	var tween = create_tween()
	tweening = true
	tween.tween_method(set_custom_size, self_size*1.1,self_size,.15)
	tween.tween_callback(pos_correction)

func set_custom_size(new_size :Vector2) :
	var new_position :Vector2 = (self.size - new_size) *.5

	pos_sum += new_position
	self.position += new_position
	self.size = new_size

func pos_correction() :
#	if index == 0 :
#		print("size : ",self.size)
#		print("pos : ",self.position)
#		print("-_-_-_-_-_-_-_-_-_-_-_-_-_-_")
	self.position -= pos_sum
	pos_sum = Vector2(.0,.0)
