extends Control
##Noeuds composant les éléments de la Timeline, il contient une frame, un label induquant son index et un bouton supprimé

@onready var Frame_n = get_node("VBoxContainer/Label") ##frame label node
@onready var frame_margin = $VBoxContainer/Frame_Margin
@onready var Frame_node = $VBoxContainer/Frame_Margin/Frame
@onready var button_node = $Button

@onready var suppr_node = $suppr

signal frame_clicked(frame,index)
signal frame_deleted(frame,index)

#Different coeficient de la taille des element
@export var coef :float = .1 ##Taille du Label par rapport à la taille de FrameUI
@export var coef_supr :float = 0.13 ##taille du bouton supprimer en % de la taille de la frame
@export var coef_margin :float = 0.05 ##Valeur de la marge autour de la frame en % de la taille fu Vbox_container - taille du label
var coef_scaling :float = 2

var resize_flag :bool = false
var index :int ##Index de la frame dans la timeline

@export var scale_factor :float = 1.01 ##Scaling de la frame lorsque hovered
var temp_frame_size
var position_temp

var margin_value_x :int
var margin_value_y :int

var base_gray = Color(.4,.4,.4)

func _ready():
	#Harmonization à la couleur du theme 
	$VBoxContainer/Frame_Margin/Frame/highlight.material.set_shader_parameter("theme_color", $"/root/MouseCursorLogic".general_theme_color)
	suppr_node.material.set_shader_parameter("theme_color", $"/root/MouseCursorLogic".general_theme_color)
	
	#Resize des differents elements composants Frame UI des son initialisation
	Frame_n.text = 'TEST'
	Frame_n.label_settings.font_size = int(self.size.y*coef)
	
	#Resize du bouton supprimer_frame
	suppr_node.hide()
	suppr_node.custom_minimum_size = self.size*coef_supr
	suppr_node.size = suppr_node.custom_minimum_size
	suppr_node.position = Frame_node.size * Vector2(1.0,.0) -  0.5*suppr_node.size

	#Resize des marges
	change_margins(frame_margin.size.x*coef_margin,frame_margin.size.x*coef_margin)


func _process(delta):
	pass

##Setter de l'index de la frame dans la timeline
func set_index(_index :int) :
	index = _index
	Frame_n.text = str(index)

##Fonction triggered lorsque Frame_UI est redimensionné par noeud parent
func _on_v_box_container_resized():
	if Frame_n!= null :
		#Resize du Label
		Frame_n.label_settings.font_size = int(self.size.y*coef)
		
		#Resize du bouton supprimer_frame
		suppr_node.custom_minimum_size = self.size*coef_supr
		suppr_node.size = suppr_node.custom_minimum_size
		suppr_node.position = -  0.3*suppr_node.size
		
		#Resize des marges
		change_margins(frame_margin.size.x*coef_margin,frame_margin.size.y*coef_margin)

##Fonction triggered lorsque le bouton de taille FrameUI est pressé (donc lorsque la frame est selectionnée dans la timeline)
func _on_button_pressed(change_cursor :bool = true):
	
	if change_cursor :
		$"/root/MouseCursorLogic".set_cursor_blue_hand_closed()
	
	Frame_n.label_settings.font_color = $"/root/MouseCursorLogic".general_theme_color
	
	frame_clicked.emit(Frame_node,index)
	#print('frame : ', Frame_node, ' clicked')
	#position_temp = self.position
#	var new_position_temp = self.position - abs(self.size*(scale_factor+.01) - self.size)/2  
	var tween = create_tween()
	
	var percent_start = coef_scaling
	var percent_target = percent_start*3
	var time = 0.035
	
	var start_margin_x :float = margin_value_x * 1/percent_start
	var start_margin_y :float = margin_value_y * 1/percent_start
	var target_margin_x :float = margin_value_x* 1/percent_target
	var target_margin_y :float = margin_value_y* 1/percent_target
	
	tween.tween_method(change_frame_margin_top,start_margin_y,target_margin_y,time)
	tween.parallel().tween_method(change_frame_margin_bottom,start_margin_y,target_margin_x,time)
	tween.parallel().tween_method(change_frame_margin_right,start_margin_x,target_margin_x,time)
	tween.parallel().tween_method(change_frame_margin_left,start_margin_x,target_margin_x,time)
	
	percent_start = percent_target
	percent_target = coef_scaling
	time = time*4
	
	start_margin_x = margin_value_x * 1/percent_start
	start_margin_y = margin_value_y * 1/percent_start
	target_margin_x = margin_value_x* 1/percent_target
	target_margin_y = margin_value_y* 1/percent_target
	
	tween.chain().tween_method(change_frame_margin_top,start_margin_y,target_margin_y,time)
	tween.parallel().tween_method(change_frame_margin_bottom,start_margin_y,target_margin_x,time)
	tween.parallel().tween_method(change_frame_margin_right,start_margin_x,target_margin_x,time)
	tween.parallel().tween_method(change_frame_margin_left,start_margin_x,target_margin_x,time)
	if change_cursor :
		tween.tween_callback($"/root/MouseCursorLogic".set_cursor_blue_hand)

##Fonction montrant ou cachant le highlight autour de la frame (appellée lorsque la frame est sleectionnée/désélectionnée)
func put_highlight(show :bool) :
	if show :
		$VBoxContainer/Frame_Margin/Frame/highlight.show()
	else :
		$VBoxContainer/Frame_Margin/Frame/highlight.hide()

##Fonction triggered lorsque la souris entre dans la frame. Aumgante la scale de la frame via Tween
func _on_button_mouse_entered(obj):
	######## Legacy animation with raster scaling ##########
#	var tween = create_tween()
#	tween.tween_property(self, "scale",Vector2(scale_factor,scale_factor), 0.08)
#	position_temp = self.position
#	var new_position_temp = self.position - abs(self.size*scale_factor - self.size)/2  
#	tween.parallel().tween_property(self, "position",new_position_temp, 0.08)
	#########################################################
	
	if suppr_node.is_hovered() or !suppr_node.visible : 
		change_frame_scale_tween(.15,1,coef_scaling)
			
		suppr_node.show()
		var t = create_tween()
		t.tween_method(modulate_suppr,.0,1.0,.15)
##Fonction triggered lorsque la souris quitte la frame. Redonne a la frame sa dimension normale
func _on_button_mouse_exited(obj):
	######## Legacy animation with raster scaling ##########
#	var tween = create_tween()
#	tween.tween_property(self, "scale",Vector2(1.0,1.0), 0.2)
#	tween.parallel().tween_property(self, "position",position_temp, 0.2)
	#########################################################
	if obj == 1 :
		suppr_node.material.set_shader_parameter('hovered',false)
	
	var obj_node = await get_non_hovered_node(obj)
	
	
	if !obj_node.is_hovered() :
		change_frame_scale_tween(.15,coef_scaling,1)
	
		var t = create_tween()
		t.tween_method(modulate_suppr,1.0,0.0,.15)
		t.tween_callback(suppr_node.hide)

func get_non_hovered_node(obj) :
	await get_tree().create_timer(0.01).timeout ## Necessaire pour que obj_node.is_hovered() soit mis à jour
	if obj == 0 :
		return suppr_node
	else :
		return button_node


func change_frame_size(container_size_x_div_coef) :
	self.custom_minimum_size = Vector2(container_size_x_div_coef,container_size_x_div_coef*1.1)

func set_input(value :bool) :
	if value :
		button_node.show()
	else :
		button_node.hide()

##Change les marges du Margin containers pour redimensionner la frame sans qu'elle déborde, via un Tween. Doit être utilisé pour changer la scale de la frame lors des animation de Hover. Percent est la scale de la frame en %, pas ds marges !
func change_frame_scale_tween(time :float, percent_start, percent_target :float) :
	var start_margin_x :float = margin_value_x * 1/percent_start
	var start_margin_y :float = margin_value_y * 1/percent_start
	var target_margin_x :float = margin_value_x*1/percent_target
	var target_margin_y :float = margin_value_y*1/percent_target
	
	var tween = create_tween()
	tween.tween_method(change_frame_margin_top,start_margin_y,target_margin_y,time)
	tween.parallel().tween_method(change_frame_margin_bottom,start_margin_y,target_margin_x,time)
	tween.parallel().tween_method(change_frame_margin_right,start_margin_x,target_margin_x,time)
	tween.parallel().tween_method(change_frame_margin_left,start_margin_x,target_margin_x,time)

##Fonction homologue à Change_frame_scale_tween, mais sans le tween, à utiliser pour changer directement la valeur des marges autour de la frame
func change_margins (value_x,value_y) :
	value_x = int(value_x)
	value_y = int(value_y)
	margin_value_x = value_x
	margin_value_y = value_y
	frame_margin.add_theme_constant_override("margin_top",value_y)
	frame_margin.add_theme_constant_override("margin_bottom",value_y)
	frame_margin.add_theme_constant_override("margin_right",value_x)
	frame_margin.add_theme_constant_override("margin_left",value_x)

##Fonctions necessaire à Change_frame_scale. Il n'est pas attendu qu'elle soit appelée
func change_frame_margin_top(value) :
	frame_margin.add_theme_constant_override("margin_top",value)
##Fonctions necessaire à Change_frame_scale. Il n'est pas attendu qu'elle soit appelée
func change_frame_margin_bottom(value) :
	frame_margin.add_theme_constant_override("margin_bottom",value)
##Fonctions necessaire à Change_frame_scale. Il n'est pas attendu qu'elle soit appelée
func change_frame_margin_right(value) :
	frame_margin.add_theme_constant_override("margin_right",value)
##Fonctions necessaire à Change_frame_scale. Il n'est pas attendu qu'elle soit appelée
func change_frame_margin_left(value) :
	frame_margin.add_theme_constant_override("margin_left",value)


func _on_suppr_pressed():
	set_input(false)
	var time_tween :float = 0.2 #Temps de disparition de la frame à la supression
	suppr_node.hide()
	change_frame_scale_tween(time_tween,coef_scaling,0.1)
	await get_tree().create_timer(time_tween).timeout
	frame_deleted.emit(Frame_n,index)

func set_pix_margin_UI() :
	#Frame_node.set_pix_margin(true)
	#Frame_node.remove_pix_margin()
	Frame_node.set_grid_container_margin()


func _on_suppr_mouse_entered():
	suppr_node.material.set_shader_parameter('hovered',true)

func modulate_suppr(alpha) :
	suppr_node.material.set_shader_parameter('alpha',alpha)

func restore_gray_font() :
	Frame_n.label_settings.font_color = base_gray
