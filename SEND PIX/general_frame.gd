extends ColorRect

var aspect_ratio :float
var line_thickness :float = 0.01
# Called when the node enters the scene tree for the first time.
func _ready():
	aspect_ratio = self.size.x /self.size.y
	self.material.set_shader_parameter('aspect_ratio',aspect_ratio)
	self.material.set_shader_parameter('line_thinckness',line_thickness)
	self.material.set_shader_parameter("theme_color",$"/root/MouseCursorLogic".general_theme_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_resized():
	aspect_ratio = self.size.x /self.size.y
	self.material.set_shader_parameter('aspect_ratio',aspect_ratio)
