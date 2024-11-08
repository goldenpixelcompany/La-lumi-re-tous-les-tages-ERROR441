extends Control

@export var delay :float = 5

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color
@onready var frame_node = $MarginContainer/ColorRect
@onready var shadow_node = $MarginContainer2/ColorRect

func _ready():
	$Timer.wait_time = delay
	shadow_node.color = theme_color
	
	frame_node.material.set_shader_parameter("aspect_ratio",self.size.x/self.size.y)
	frame_node.material.set_shader_parameter("line_thinckness",.01)
	frame_node.material.set_shader_parameter('theme_color',theme_color)

func _process(delta):
	pass

func start_show() :
	self.show()
	$Timer.start()
	var tween = create_tween()
	tween.tween_property(self,"position:y",.0,1.).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_timer_timeout():
	self.hide()
	var tween = create_tween()
	tween.tween_property(self,"position:y",3000,1.).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
