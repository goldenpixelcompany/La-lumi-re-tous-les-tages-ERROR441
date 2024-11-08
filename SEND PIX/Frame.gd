extends Control

var mouse_on_pix
var mouse_clicked :bool = false

var main :bool = false

var bucket_mode :bool = true

const screen_rez = 21 
var xyscreen_res :Vector2i = Vector2i(21,21)
@onready var grid_node = get_node("MarginContainer/GridContainer")
@onready var pix_scene = preload("res://pix.tscn") 
@onready var frame_shader = preload("res://general_frame_shader.gdshader")
@onready var gml = $"/root/MouseCursorLogic"

@export var pix_margin :float 
@export var pix_margin_UI :float

var state_stack = [] ## Pile qui stoque les états successifs de la frame (pour le ctrl+Z)

signal pixel_clicked(pix_color,pix_index)
signal new_input_start()

func _ready():
	
	xyscreen_res = gml.screen_rez
	
	
	grid_node.columns = xyscreen_res.x
	var temp_pix
	for pos in range(xyscreen_res.x*xyscreen_res.y) :
		temp_pix = pix_scene.instantiate()
		grid_node.add_child(temp_pix)
		temp_pix = grid_node.get_child(grid_node.get_child_count()-1)
		temp_pix.pix_index = pos
		temp_pix.mouse_entered_pix.connect(on_mouse_entered)
		temp_pix.mouse_exited_pix.connect(on_mouse_exited)
	
	state_stack.append(self.get_frame_picture())
	#print(len(state_stack))

func _input(event):
	if mouse_on_pix != null :
		if event is InputEventMouseButton :
			if event.button_index == MOUSE_BUTTON_LEFT  :
				if event.is_pressed() :
					mouse_clicked = true
					new_input_start.emit()
					on_mouse_entered(mouse_on_pix,mouse_on_pix.get_parent().get_parent().pix_index)
					gml.set_cursor_blue_hand_closed()
				elif event.is_released() :
					mouse_clicked = false
					gml.set_cursor_blue_hand()

func _process(delta):
	if main :
		if mouse_clicked :
			#print("testing")
			if gml.mouse_clicked == false :
				mouse_clicked = false

func on_mouse_entered(pix_node_emiting,pix_index) -> void :
	
	mouse_on_pix = pix_node_emiting
	if mouse_clicked :
		#mouse_on_pix.color = Color(1.0,.0,.0)
		pixel_clicked.emit(mouse_on_pix.color,pix_index)
	
func on_mouse_exited(pix_node_emiting,pix_index) -> void :
	mouse_on_pix = null

func get_frame_picture () -> Array[Color] :
	var picture :Array[Color]
	for pix in grid_node.get_children() :
		picture.append(pix.colorRect_node.color)
	return picture

func set_frame_picture (new_picture :Array[Color]) -> void :
	for i in range(grid_node.get_child_count()) :
		grid_node.get_child(i).colorRect_node.color = new_picture[i]

func set_frame_picture_pix(color :Color,pix_index :int) -> void :
	grid_node.get_child(pix_index).colorRect_node.color = color

func set_pix_margin(is_UI :bool) -> void :
	var aspect_ratio :float = self.size.x/self.size.y
	if self.size.y == .0 :
		aspect_ratio = 1
	var margin_value :float
	if is_UI :
		margin_value = pix_margin_UI
	else :
		margin_value = self.xyscreen_res.x/self.size.x * pix_margin
		set_cadre(aspect_ratio)
	for pix in grid_node.get_children() :
		pix.set_pix_margin(margin_value,aspect_ratio)

func remove_pix_margin() -> void :
	for pix in grid_node.get_children() :
		pix.remove_margin()

func set_grid_container_margin() -> void :
	remove_pix_margin()
	grid_node.add_theme_constant_override("h_separation",1)
	grid_node.add_theme_constant_override("v_separation",1)

func set_cadre(ar) : #Marche pas on sait pas pk
	$ColorRect.material.shader = frame_shader
	
	$ColorRect.material.set_shader_parameter("aspect_ratio", ar)
	$ColorRect.material.set_shader_parameter("line_thickness",.03)
	$ColorRect.material.set_shader_parameter("alpha", 1.0)
	$ColorRect.material.set_shader_parameter("theme_color", $/root/MouseCursorLogic.general_theme_color)


func set_ghost_frame(ghost_frame :Array[Color]) -> void :
	#print(ghost_frame)
	var pix_ghost_color :Color
	for i in range(grid_node.get_child_count()) :
		if grid_node.get_child(i).colorRect_node.color == Color(.0,.0,.0) :
			#print("pix ghost set")
			pix_ghost_color = ghost_frame[i]
			if pix_ghost_color != Color(.0,.0,.0) :
				pix_ghost_color.a = 0.1
				grid_node.get_child(i).colorRect_node.color = pix_ghost_color
			

func whipe_state_stack() -> void :
	state_stack = []
