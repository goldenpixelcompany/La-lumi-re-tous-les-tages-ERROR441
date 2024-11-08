extends HBoxContainer

@onready var button_array = [$back,$play,$forward]

var playing :bool = false

signal tl_input(step :int)
signal play_stop_input(play:bool)

func set_buttons_color(color:Color) :
	for node in button_array :
		node.material.set_shader_parameter('line_color',color)


func _on_resized():
	self.custom_minimum_size.x = self.size.y * 3
	self.size.x = self.custom_minimum_size.x


func _on_back_pressed():
	tl_input.emit(-1)


func _on_play_pressed():
	playing = !playing
	$play.material.set_shader_parameter('forward',playing)
	play_stop_input.emit(playing)


func _on_forward_pressed():
	tl_input.emit(1)
