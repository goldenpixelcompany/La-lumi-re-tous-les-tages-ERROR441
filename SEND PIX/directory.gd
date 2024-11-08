extends Control

var dir_path : String
var single_click :bool = false

signal dir_selected(path :String)


func _ready():
	pass # Replace with function body.



func _process(delta):
	pass


func _on_button_pressed():
	if single_click :
		dir_selected.emit(dir_path)
	else :
		single_click = true


func _on_button_mouse_entered():
	pass # Replace with function body.


func _on_button_mouse_exited():
	pass # Replace with function body.


func _on_timer_timeout():
	pass # Replace with function body.
