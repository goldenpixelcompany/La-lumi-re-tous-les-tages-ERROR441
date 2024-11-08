extends Control

##Necessite un general_frame_shader.gdshader pour fonctionner (on pourrait l'ajouter via code)

var down_margin_ratio :float = .2 
var up_margin_ratio :float = .05
var line_alpha :float : set = set_line_alpha
var tempo :int = 160 

func set_line_alpha(value: float) :
	line_alpha = value
	self.material.set_shader_parameter("line_alpha",1-line_alpha)


var beating :bool = false
var beat_compte :int

var down_time_ratio :float = 0.7

var aspect_ratio :float

func _ready():
	_on_resized()
	start_beat()
	self.material.set_shader_parameter("line_alpha",1-line_alpha)
	self.material.set_shader_parameter("beat_mode",true)
	self.material.set_shader_parameter("alpha",1)

func stop_beat() :
	beating = false
	
func start_beat(n_times :int = -1) :
	beating = true
	beat_compte = 0
	beat(n_times)
	
func beat(n_times :int = -1 ) : # -1 est jusqu' a ce que stop_beat() est appellé 
	if n_times == 0 :
		stop_beat()
	if beating :
		var time1 :float =  60.0/float(tempo)*down_time_ratio
		var time2 :float= 60.0/float(tempo)*(1-down_time_ratio)
		
		var tween = create_tween()
		tween.tween_method(set_margin,down_margin_ratio,up_margin_ratio, time1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.chain().tween_method(set_margin, up_margin_ratio, down_margin_ratio, time2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		tween.tween_callback(beat.bind(n_times-1))

func set_margin(value :float) :
	self.material.set_shader_parameter("line_thinckness",value)

func _on_resized():
	await get_tree().create_timer(.1).timeout
	aspect_ratio = self.size.x/self.size.y 
	self.material.set_shader_parameter("aspect_ratio",1.0)
