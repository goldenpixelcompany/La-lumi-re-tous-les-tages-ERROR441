extends Button

@export var scale_factor :float = 1.02
var pos_temp :Vector2 

var tween_entered
var tween_exited

var color_factor :float = .6

# Called when the node enters the scene tree for the first time.
func _ready():
	self.material.set_shader_parameter("color_factor",color_factor)
	pos_temp = self.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	tween_entered = create_tween()
	if tween_exited != null :
		if !tween_exited.is_running() :
			pos_temp = self.position
			print('pos_temp_updated')
	else :
		pos_temp = self.position
	tween_entered.tween_property(self, "scale",Vector2(scale_factor,scale_factor), 0.08)
	tween_entered.parallel().tween_property(self,'position',pos_temp - 0.5*abs(self.size*(scale_factor-1)),0.08)
	self.material.set_shader_parameter("hovered",true)
	self.material.set_shader_parameter("line_thickness",.04)
	self.material.set_shader_parameter("color_factor",1.)

func _on_mouse_exited():
	tween_exited = create_tween()
	tween_exited.tween_property(self, "scale",Vector2(1.0,1.0), 0.2)
	tween_exited.parallel().tween_property(self,'position',pos_temp,0.2)
	material.set_shader_parameter("hovered",false)
	self.material.set_shader_parameter("line_thickness",.025)
	self.material.set_shader_parameter("color_factor",color_factor)

func _on_pressed():
	var tween = create_tween()
#	if tween_exited != null :
#		if !tween_exited.is_running() :
#			pos_temp = self.position
#			print('pos_temp_updated')
#	else :
#		pos_temp = self.position
	self.position = pos_temp
	tween.tween_property(self, "scale",Vector2(3*scale_factor-2,3*scale_factor-2), 0.02)
	tween.parallel().tween_property(self,'position',pos_temp - 0.5*abs(self.size*((3*scale_factor-2)-1)),0.08)
	tween.chain().tween_property(self, "scale",Vector2(1.0,1.0), 0.2)
	tween.parallel().tween_property(self,'position',pos_temp,0.2)
	tween.parallel().tween_method(set_color_factor,1.0,color_factor,.35).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func set_color_factor(value :float) :
	self.material.set_shader_parameter("color_factor",value)
