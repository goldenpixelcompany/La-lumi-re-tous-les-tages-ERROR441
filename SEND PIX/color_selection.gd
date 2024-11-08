extends Control

var mouse_clicked :bool = false
var base_color_ratio :float = .6
var hovered :bool = false

@onready var cursor_node = $cursor
@onready var color_wheel_node = $color_wheel

var wheel_size :float 
var center :Vector2

var cursor_size :float 
var cursor_size_factor :float = 0.1
var cursor_polar_pos :Vector2

var selected_color :Color : set = set_selected_color

func set_selected_color_to(color : Color, cursor_pos : Vector2) : ## Met la wheel et son curseur à la couluer donnée en argumnt (ne doit être appellée que parl es noeuds parents)
	var tween = create_tween()
	cursor_polar_pos = cursor_pos
	set_cursor_polar_pos(cursor_pos)
	cursor_node.color = color




func set_selected_color(color :Color) : ##  Seter de la variable selected_color (ne doit êtr appelée que par les noeud enfant
	selected_color = color
	color_selected_change.emit(color)

@export var FSD :float = 0.7 	#Paramètre de la roue de couleur Full Saturation Distance, contrôle la distance au centre à partir de laquelle la couleur est désaturée au blanc
@export var FSA :float = 2.0 	#Paramètre de la rour de couleur Full Saturation Angle, contrôle la durée (angle) pendant la quelle chaque couleur primaire est pleinement saturée.

signal color_selected_change(new_color :Color, new_cursor_pos :Vector2)

func _ready():
	_on_resized()
	
	color_wheel_node.material.set_shader_parameter("FSD",FSD)
	color_wheel_node.material.set_shader_parameter("FSA",FSA)
	color_wheel_node.material.set_shader_parameter("theme_color",$/root/MouseCursorLogic.general_theme_color)


func _input(event):
	

	if event is InputEventMouseButton :
		
		if event.button_index == MOUSE_BUTTON_LEFT :
			#print('event_pos : ', event.position)
			var event_relative_pos :Vector2 = event.position - self.global_position
			#print('event relative pos : ',event_relative_pos)
			var input_valid :bool = (event_relative_pos.x < self.size.x and event_relative_pos.y < self.size.y) and (event_relative_pos.x >= 0 and event_relative_pos.y >= 0)
			if event.is_pressed() and input_valid:
				$"/root/MouseCursorLogic".set_cursor_blue_hand_closed()
				mouse_clicked = true
				move_cursor(event_relative_pos)
			elif event.is_released() :
				var is_valid :bool = !is_mouse_in_object(color_wheel_node) and mouse_clicked
				mouse_clicked = false
				if is_valid :
					_on_color_wheel_mouse_exited()
				$"/root/MouseCursorLogic".set_cursor_blue_hand()
	elif event is InputEventMouseMotion and mouse_clicked :
		var event_relative_pos :Vector2 = event.position - self.global_position
		$"/root/MouseCursorLogic".set_cursor_blue_hand_closed()
		move_cursor(event_relative_pos)


func move_cursor (event_pos :Vector2) :
	event_pos = event_pos - center
	var target_pos :Vector2 = center + event_pos.normalized()*min(wheel_size/2.0,event_pos.length())
	target_pos -= Vector2(cursor_size/2,cursor_size/2)
	var tween = create_tween()
	#tween.tween_property(cursor_node,"position",target_pos,0.2) 
	tween.tween_method(set_cursor_cart_pos,cursor_node.position,target_pos,0.2)



func set_cursor_cart_pos(cart :Vector2) :
	cursor_node.position = cart
	cursor_polar_pos = cart_to_polar(cart)
	selected_color = polar_pos_to_color(cart_to_polar(cart+Vector2(cursor_size/2,cursor_size/2)))


func set_cursor_polar_pos(polar : Vector2) :
	var radius :float = wheel_size/2.0
	var teta = polar.x *PI
	var r = min(1.0,polar.y )* radius
	var pix_pos :Vector2 = center
	
	pix_pos.x += sin(teta) * r
	pix_pos.y += cos(teta) * r
	
	cursor_node.position = pix_pos
	
func set_cursor_to_color(color :Color, tween_on :bool = true) :
	pass #C'est compliqué, un work-around consiste à aussi stocker la position sur la wheel, en plus de la couleur, dans les slots de la palette de couleur
	

func color_to_polar_pos(color :Color) :
	pass #C'est compliqué, Future improvement : trouvé l'inverse de la fonction définissant la color wheel (ça n'a pa s l'air très injectif tout ça)


func polar_pos_to_color(polar : Vector2) :
	
	var teta :float = polar.x
	var r :float = polar.y
	var color :Color
	var coef :float = 2.0/3.0
	
	color.r = corrected(teta/coef)
	color.g = corrected((teta+coef)/coef)
	color.b = corrected(-teta/coef)
	
	color.r *= min(1.0,r/FSD)
	color.g *= min(1.0,r/FSD)
	color.b *= min(1.0,r/FSD)

	color.r += (int(r) + int(r/FSD)*(r-FSD)/(1.0-FSD))
	color.g += (int(r) + int(r/FSD)*(r-FSD)/(1.0-FSD))
	color.b += (int(r) + int(r/FSD)*(r-FSD)/(1.0-FSD))
	return color

func corrected(value :float) :
	
	if floorf(abs(value))== 1.0 :
		return (1.0-fract(value))*FSA
	elif floorf(value) < 0 or floorf(value) == 2.0 :
		return .0
	else :
		return (fract(value))*FSA


func cart_to_polar(cart :Vector2) :
	cart = cart-center
	var teta = atan2(cart.x,cart.y)/PI
	var r = cart.length()/wheel_size
	
	return Vector2(teta,2*r)


func _on_color_selected_change(new_color):
	cursor_node.color = new_color
	color_wheel_node.color = new_color

func fract (val :float) :
	return val-floorf(val)


func _on_resized():
	if color_wheel_node != null :
		wheel_size = min(self.size.x, self.size.y)
		center = color_wheel_node.position + Vector2(wheel_size/2.0,wheel_size/2.0)
		color_wheel_node.custom_minimum_size = Vector2(wheel_size,wheel_size)
		color_wheel_node.size = Vector2(wheel_size,wheel_size)
		
		color_wheel_node.position = self.size/2.0 - color_wheel_node.size/2.0
		center = color_wheel_node.position + Vector2(wheel_size/2.0,wheel_size/2.0)
		
		cursor_size = wheel_size * cursor_size_factor
		cursor_node.size = Vector2(cursor_size,cursor_size)
		set_cursor_polar_pos(cursor_polar_pos)


func _on_color_wheel_mouse_entered():
	if !hovered :
		hovered = true
		set_wheel_color_factor(1.)


func _on_color_wheel_mouse_exited():
	if !mouse_clicked and !is_mouse_in_object(color_wheel_node):
		var tween = create_tween ()
		tween.tween_method(set_wheel_color_factor, 1., base_color_ratio, .15)
		hovered = false

func set_wheel_color_factor(value :float ) :
	color_wheel_node.material.set_shader_parameter("color_factor",value)

func is_mouse_in_object(object) :
	return Rect2(object.position, object.size).has_point(get_local_mouse_position())
