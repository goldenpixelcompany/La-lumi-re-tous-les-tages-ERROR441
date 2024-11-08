extends Control

var button_pressed: bool = false 
var position_changing :bool = false
var position_percent :float = .0

const x_offset :int = 10

var color_coef :float = 0.7
@onready var color_theme :Color = $"/root/MouseCursorLogic".general_theme_color

var target_pos_y = 0 

signal position_changed(position)

func _ready():
	$line.custom_minimum_size = Vector2(self.size.x /2,self.size.y)
	$line.color = $"/root/MouseCursorLogic".general_theme_color
	$Button.material.set_shader_parameter("theme_color", $"/root/MouseCursorLogic".general_theme_color)
	$Button.material.set_shader_parameter("color_coef",1.0)
	
	#$line.position.x += 8.5
	#$Button.position.x = x_offset
	_on_mouse_exited()

func _process(delta): 
	if position_changing :
		position_percent = $Button.position.y/(self.size.y-$Button.size.y)
		position_changed.emit(position_percent)
		#print('position in percent : ',position_percent)

func _on_button_button_down():
	if !button_pressed :
		target_pos_y = $Button.position.y
		position_changing = true
	$"/root/MouseCursorLogic".set_cursor_blue_hand_closed()
	button_pressed = true 
	

func _input(event):
	if event is InputEventMouseMotion and button_pressed:
		target_pos_y += event.relative.y
		move_bar(target_pos_y)
		$"/root/MouseCursorLogic".set_cursor_blue_hand_closed()

func set_bar_size (percent) : #marche pas bien à priori
	if percent == 1 :
		self.hide()
	else :
		self.show()
		var tween = create_tween()
		#print('about_to_tween')
		$Button.custom_minimum_size.x = self.size.x
		tween.tween_property($Button,'custom_minimum_size:y',self.size.y*percent,0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property($Button,'size:y',self.size.y*percent,0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		#tween.tween_callback(print_check)
		
		$line.custom_minimum_size.x = self.size.x/10

func _on_button_button_up():
	button_pressed = false
	position_changing = false
	$"/root/MouseCursorLogic".set_cursor_blue_hand()
	_on_mouse_exited()

func move_bar(_target_pos_y) : #Marche bien à priori
	var tween = create_tween()
	if _target_pos_y < 0 :
		_target_pos_y = 0
	elif _target_pos_y > (self.size.y - $Button.size.y) :
		_target_pos_y = self.size.y - $Button.size.y
	tween.tween_property($Button,'position',Vector2($Button.position.x,_target_pos_y),0.3)

func print_check() :
	print('callback size : ',$Button.size)


func _on_button_focus_entered():
	print("MOUSE NTERED SCROLLBARR")
	$Button.material.set_shader_parameter("color_coef",1.0)
	$line.color = $"/root/MouseCursorLogic".general_theme_color

func _on_button_focus_exited():
	print("mouse exited?")
	$Button.material.set_shader_parameter("color_coef",color_coef)
	$line.color = $"/root/MouseCursorLogic".general_theme_color*color_coef



func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_method(set_color_ratio,color_coef,1.,.1)

func set_color_ratio(ratio :float) :
	$Button.material.set_shader_parameter("color_coef",ratio)
	$line.color = color_theme*ratio




func _on_mouse_exited():
	if !button_pressed :
		var tween = create_tween()
		tween.tween_method(set_color_ratio,1.,color_coef,.3)
