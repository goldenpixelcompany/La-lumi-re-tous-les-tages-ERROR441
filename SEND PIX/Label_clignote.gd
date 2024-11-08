extends Label

@export var frequence :float = .5
var delta_buff :float = 0
var possible_colors :Array[Color] = [Color.RED,Color.BLUE,Color.PURPLE,Color.GREEN,Color.CYAN]
var i :int = 0
@export var font_base_size : int = 400

func _ready():
	set_font_size(font_base_size)


func _process(delta):
	delta_buff = delta_buff +  delta
	if delta_buff > frequence :
		delta_buff = 0
		self.label_settings.font_color = possible_colors[i%possible_colors.size()]
		i+=1
		#var tween = create_tween()
		#tween.tween_method(set_font_size, font_base_size*1.2,font_base_size,frequence).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		

func set_font_size(new_size :int) :
	self.label_settings.font_size = new_size
