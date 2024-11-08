extends Node2D

var blue_hand_closed = preload("res://icons/main_bleue_closed.png")
var blue_hand = preload("res://icons/main_bleue.png")
var pencil_hand = preload("res://icons/pencil_hand.png")
var bucket_hand = preload("res://icons/bucket_hand.png")

@export var general_theme_color :Color = Color(1.0,.75,0.0)
@export var screen_rez : Vector2i = Vector2i(21,21) ## Resolution de l'installation !! 

var is_playing :bool = false
var mouse_clicked :bool = false

func _input(event):
	if event is InputEventMouseButton :
		if event.button_index == MOUSE_BUTTON_LEFT  :
			if event.is_pressed() :
				mouse_clicked = true
			elif event.is_released() :
				mouse_clicked = false

func _ready():
	set_cursor_blue_hand()


func set_cursor_blue_hand() :
	Input.set_custom_mouse_cursor(blue_hand,0,Vector2(20,20))

func set_cursor_blue_hand_closed() :
	Input.set_custom_mouse_cursor(blue_hand_closed)

func set_cursor_default() :
	Input.set_custom_mouse_cursor(null)

func set_cursor_pencil() :
	Input.set_custom_mouse_cursor(pencil_hand)

func set_cursor_bucket() :
	Input.set_custom_mouse_cursor(bucket_hand)
