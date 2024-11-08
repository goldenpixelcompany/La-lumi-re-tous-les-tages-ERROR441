extends Control

@export var down_margin_ratio :float = .2 : set = set_down_margin_ratio ##Taille du rectangle sur le beat (More = Smaller)
@export var up_margin_ratio :float = .05 : set = set_up_margin_ratio ##Taille du rectangle sur let contre-temps (Less = Bigger)

func set_down_margin_ratio (value :float) :
	down_margin_ratio = value
	if back_rect_node != null :
		back_rect_node.down_margin_ratio = down_margin_ratio
		clipped_rect_node.down_margin_ratio = down_margin_ratio

func set_up_margin_ratio (value :float) :
	up_margin_ratio = value
	if back_rect_node != null :
		back_rect_node.up_margin_ratio = up_margin_ratio
		clipped_rect_node.up_margin_ratio = up_margin_ratio

@export var tempo :int = 160 : set = set_tempo ##BPM

func set_tempo(value :int) :
	tempo = value 
	if back_rect_node != null :
		back_rect_node.tempo = tempo
		clipped_rect_node.tempo = tempo

@export var rect_color :Color : set = set_rect_color ##Couleur du rectangle
@export var text_color :Color : set = set_text_color ##Couleur du Text

func set_rect_color(color :Color) :
	rect_color = color
	if back_rect_node != null :
		back_rect_node.color = rect_color

func set_text_color(color :Color) :
	text_color = color
	if back_rect_node != null :
		clipped_rect_node.color = text_color

@export var letter_space :int : set = set_letter_space ##Espacement entre les lettres
@export var letter_transform :Transform2D = Transform2D(Vector2(1.0,.0),Vector2(.0,1.0),Vector2(.0,.0)) : set = set_letter_transform ##Transformation des lettres
@export var text_position :Vector2 : set = set_text_position ##Position du text, Work around pour font transform origin not working

func set_letter_space(value :int) :
	letter_space = value
	if back_rect_node != null :
		label_node.label_settings.font.spacing_glyph = value

func set_letter_transform(value :Transform2D) :
	letter_transform = value
	if back_rect_node != null :
		label_node.label_settings.font.variation_transform = value

func set_text_position(value :Vector2) :
	text_position = value
	if back_rect_node != null :
		label_node.material.set_shader_parameter("offset",value)

@export var text :String : set = set_text ##Text affiché

func set_text(txt : String) :
	text = txt
	if back_rect_node != null :
		label_node.text = text

@export var font_size_ratio :float = .2 ##Taille de la police relativement à la taille du noeud de contrôle

@onready var back_rect_node = $Back_ColorRect 
@onready var label_node = $Label
@onready var clipped_rect_node = $Label/Clipped_ColorRect

@export var rectangle_offset :Vector2i :set = set_rectangle_offset

func set_rectangle_offset(value:Vector2i) :
	rectangle_offset = value
	if back_rect_node != null :
		back_rect_node.position = value
		clipped_rect_node.position = value

func _ready():
	set_tempo(tempo)
	
	set_down_margin_ratio(down_margin_ratio)
	set_up_margin_ratio(up_margin_ratio)
	
	set_rect_color(rect_color)
	set_text_color(text_color)
	
	set_text(text)
	set_letter_space(letter_space)
	set_letter_transform(letter_transform)
	set_text_position(text_position)
	
	set_rectangle_offset(rectangle_offset)
	
	clipped_rect_node.line_alpha = 1.0
	back_rect_node.line_alpha = .0
	
	await get_tree().create_timer(.05).timeout
	_on_resized()

func start_beat(n_times : int = -1) :
	back_rect_node.start_beat(n_times)
	clipped_rect_node.start_beat(n_times)

func stop_beat() :
	back_rect_node.stop_beat()
	clipped_rect_node.stop_beat()

func _on_resized():
	if label_node != null :
		label_node.label_settings.font_size = self.size.x*font_size_ratio
