extends Button

var scale_factor :float = 1.01
var line_thickness :float = .03
var color_ratio :float = .7

func _ready():
	self.material.set_shader_parameter("theme_color",$"/root/MouseCursorLogic".general_theme_color)
	self.material.set_shader_parameter("color_ratio",color_ratio)

func _process(delta):
	pass


func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale",Vector2(scale_factor,scale_factor), 0.08)
	self.material.set_shader_parameter("line_thickness", line_thickness*2)
	self.material.set_shader_parameter("color_ratio",1.)


func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale",Vector2(1.0,1.0), 0.2)
	self.material.set_shader_parameter("line_thickness", line_thickness)
	self.material.set_shader_parameter("color_ratio",color_ratio)
