extends Control

@onready var label_node = $VBoxContainer/HBoxContainer2/Label
@onready var clear_button_node = $VBoxContainer/HBoxContainer2/ClearLabel
var font_color_factor :float = .85
var clear_size :float = 0.5 ##Taille de la font pour le bouton clear relativement au label IMAGE

var hovered:bool = false

@onready var grid_node = $VBoxContainer/HBoxContainer/ScrollContainer/MarginContainer/GridContainer
@onready var add_frame_node = $VBoxContainer/HBoxContainer/ScrollContainer/MarginContainer/GridContainer/add_frame
@onready var frame_node = preload("res://frame_ui.tscn")

@onready var scroll_bar_node = $VBoxContainer/HBoxContainer/c_scroll_bar
@onready var scroll_container_node = $VBoxContainer/HBoxContainer/ScrollContainer

@onready var theme_color = $/root/MouseCursorLogic.general_theme_color

var bar_size_percent :float = 1
var coef :float = 0.06 ##Font coef size
var columns_n 
var selected 
@export var frames_coef :float = 2.45 ##Taille des frame de la timeline ( = taille container/frames_coef)

signal changed_selected_frame(frame,index)
signal update_ghost(ghost_frame_picture :Array[Color])
signal signal_frame_deleted(index)
signal tl_clearing()

func _ready():
	label_node.label_settings.font_size = $VBoxContainer.size.y * coef
	label_node.label_settings.font_color = theme_color
	clear_button_node.label_settings.font_color = theme_color*font_color_factor
	#print(grid_node.size.x)
	#columns_n = int(grid_node.size.x) / 300
	#print(columns_n)
	grid_node.columns = 2
	await get_tree().create_timer(0.5).timeout
	_on_add_frame_pressed()
	select_frame(0)


func _process(delta):
	if is_mouse_in_object(self) and !hovered :
		hovered = true
		var tween = create_tween()
		tween.tween_method(set_image_label_color_factor,.9,1.,.1)
	elif !is_mouse_in_object(self) and hovered :
		hovered = false
		var tween = create_tween()
		tween.tween_method(set_image_label_color_factor,1.,.9,.5)

func _input(event):
	if event is InputEventMouse :
		if  event.button_mask%8 == 0 and event.button_mask != 0 :
			update_scroll_bar_pos()


func get_frame(index :int) : ##Renvois la reference de la frame (!UI) d'index arg 
	return grid_node.get_child(index).Frame_node

func _on_v_box_container_resized():
	if label_node != null :
		label_node.label_settings.font_size = $VBoxContainer.size.y * coef
		clear_button_node.label_settings.font_size = $VBoxContainer.size.y * coef * clear_size
		#columns_n = int(grid_node.size.x) / 300
		#print(columns_n)
		#grid_node.Columns = columns_n
		for i in range(grid_node.get_child_count()-1) :
			grid_node.get_child(i).change_frame_size($VBoxContainer.size.x/frames_coef)
		grid_node.get_child(-1).custom_minimum_size = Vector2($VBoxContainer.size.x/frames_coef,$VBoxContainer.size.x/frames_coef*1.1)
		
		
		print('grid_container size   : ',grid_node.size.y)
		print('scroll_container size : ', scroll_container_node.size.y)
		if scroll_container_node.size.y != 0 :
			bar_size_percent = min(1.0,scroll_container_node.size.y/grid_node.size.y)
			print('bar_resized_to : ', bar_size_percent)
			scroll_bar_node.set_bar_size(bar_size_percent)
			update_scroll_bar_pos()



func _on_add_frame_pressed():
	grid_node.add_child(frame_node.instantiate())
	add_frame_node.move_to_front()
	
	var new_frame = grid_node.get_child(-2)
	new_frame.set_index(grid_node.get_child_count()-2)
	new_frame.frame_clicked.connect(on_frame_clicked)
	new_frame.frame_deleted.connect(on_frame_deleted)
	new_frame.set_pix_margin_UI()
	
	#mettre scroll a 100%
	var tween = create_tween()
	#update_scroll_bar_to_pos(grid_node.size.y)
	#tween.tween_property(scroll_container_node,'scroll_vertical', grid_node.size.y, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#Ya aucun interet a faire avec size, juste faire avec scale !!
	tween.parallel().tween_method(new_frame.change_frame_size,$VBoxContainer.size.x/10/frames_coef,$VBoxContainer.size.x/frames_coef,0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#tween.parallel().tween_property(new_frame,'scale',Vector2(1.05,1.05),0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#tween.chain().tween_property(new_frame,'scale',Vector2(1.0,1.0),0.1)
	tween.tween_callback(new_frame.set_input.bind(true))
	tween.tween_callback(new_frame._on_button_pressed.bind(false))
	
	#print('grid_container size   : ',grid_node.size.y)
	#print('scroll_container size : ', scroll_container_node.size.y)
	bar_size_percent = min(1.0,scroll_container_node.size.y/grid_node.size.y)
	#print('bar_resized_to : ', bar_size_percent)
	scroll_bar_node.set_bar_size(bar_size_percent)

	


func select_frame (index,is_playing :bool = false) :
	if index >= 0 and grid_node.get_child_count()!= 0 :
		index = index % (grid_node.get_child_count()-1)
		grid_node.get_child(index)._on_button_pressed(!is_playing)
		return index
	else : 
		return 0


func on_frame_clicked(frame_clicked,index) :
	selected = frame_clicked
	
	#Update de la ghost frame
	if !$"/root/MouseCursorLogic".is_playing and (index-1) >= 0:
		update_ghost.emit(grid_node.get_child(index-1).Frame_node.get_frame_picture())
	
	#On récupère le frame_UI de la frame clicked, c'est un un peu overcomplcated tout ça
	var frame_clicked_node
	for i in range(grid_node.get_child_count()-1) :
		if i != index :
			grid_node.get_child(i).put_highlight(false)
			grid_node.get_child(i).restore_gray_font()
		else :
			frame_clicked_node = grid_node.get_child(i)
			frame_clicked_node.put_highlight(true)
			
	scroll_to_selected_frame(frame_clicked_node)
	changed_selected_frame.emit(frame_clicked,index)

func scroll_to_selected_frame(frame) :
	var scroll_value = frame.position.y + 0.5*frame.size.y - 0.5*scroll_container_node.size.y
	if scroll_value < 0 :
		scroll_value = 0
	else :
		scroll_value = min(grid_node.size.y - scroll_container_node.size.y, scroll_value)
	var tween = create_tween()
	tween.tween_property(scroll_container_node,'scroll_vertical', scroll_value, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	update_scroll_bar_to_pos(scroll_value)

func on_frame_deleted(frame_deleted,index) :
	var frame_deleted_node
	grid_node.get_child(index).queue_free()
	await get_tree().create_timer(0.01).timeout
	var frame_count :int = grid_node.get_child_count()-1
	if frame_count > 0 :
		for i in range(frame_count) :
			print('index_set_to ', i )
			grid_node.get_child(i).set_index(i)
		signal_frame_deleted.emit(index)

func _on_c_scroll_bar_position_changed(scroll_value):
	scroll_container_node.scroll_vertical = scroll_value * (grid_node.size.y - self.size.y*0.9)

func update_scroll_bar_pos() :
	var scroll_target = (scroll_container_node.scroll_vertical / (grid_node.size.y -scroll_container_node.size.y)) * (scroll_bar_node.size.y - scroll_bar_node.get_child(1).size.y)
	scroll_bar_node.move_bar(scroll_target)

func update_scroll_bar_to_pos(_scroll_value) :
	var scroll_target = (_scroll_value / (grid_node.size.y -scroll_container_node.size.y)) * (scroll_bar_node.size.y - scroll_bar_node.get_child(1).size.y)
	scroll_bar_node.move_bar(scroll_target)


func _on_grid_container_resized():
	if scroll_container_node != null :
		_on_c_scroll_bar_position_changed(scroll_bar_node.position_percent)


func get_frame_picture_sequence() :
	var frame_count :int = grid_node.get_child_count()-1
	if frame_count > 0 :
		var img_seq = []
		for i in range(frame_count) :
			img_seq.append(grid_node.get_child(i).Frame_node.get_frame_picture())
		return img_seq
	else :
		return []


func _on_clear_button_mouse_entered():
	set_clear_button_color_factor(1.)


func _on_clear_button_mouse_exited():
	var tween = create_tween()
	tween.tween_method(set_clear_button_color_factor,1.,font_color_factor,0.1)

func _on_clear_button_pressed():
	clear_timeline()

func clear_timeline() :
	tl_clearing.emit()
	for node in grid_node.get_children() :
		if node != add_frame_node :
			await node._on_suppr_pressed()
	await _on_add_frame_pressed()
	select_frame(0)

func delete_frame(index :int) :
	grid_node.get_child(index)._on_suppr_pressed() 

func set_clear_button_color_factor(factor :float) :
	clear_button_node.label_settings.font_color = theme_color * factor

func set_image_label_color_factor(factor :float) :
	label_node.label_settings.font_color = theme_color * factor


func is_mouse_in_object(object) :
	return Rect2(object.position, object.size+Vector2(.0,1000)).has_point(get_local_mouse_position())
