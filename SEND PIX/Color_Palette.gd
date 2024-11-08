extends Control

const nbr_palette_slot :int = 10
const margin_slot_size :float = .15
const wheel_margin :float = .05

const label_size :float = .12
const label_color_factor :float = .4

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color

@onready var palette_slot_scene = preload("res://palette_slot.tscn")
@onready var grid_node = $VBoxContainer/GridContainer
@onready var wheel_node = $VBoxContainer/wheel_container/Color_selection
@onready var label_node = $VBoxContainer/Label
@onready var line_node = $VBoxContainer/Label/line 

var selected_color_slot = null #Reference du noeud selectionné 
var selected_color_slot_index :int

var selected_color :Color : get = get_selected_color

func get_selected_color() :
	return selected_color_slot.color

func select_slot(slot_index :int) :
	selected_color_slot_index = slot_index
	selected_color_slot = grid_node.get_child(slot_index)
	wheel_node.set_selected_color_to(selected_color_slot.color,selected_color_slot.cursor_pos)

func _ready():
	for i in range(nbr_palette_slot) :
		var new_color_slot = palette_slot_scene.instantiate()
		new_color_slot.index = i
		grid_node.add_child(new_color_slot)
		new_color_slot.connect("slot_selected",on_slot_selected)
	
	label_node.label_settings.font_color = theme_color
	
	select_slot(0)
	grid_node.get_child(0).color = wheel_node.selected_color
	_on_resized()


func on_slot_selected(slot_color :Color, slot_index :int) :
	var slot_to_unselect_index = selected_color_slot_index
	select_slot(slot_index)
	grid_node.get_child(slot_to_unselect_index).unselect()


func _on_color_selection_color_selected_change(new_color):
	selected_color_slot.color = new_color
	selected_color_slot.cursor_pos = wheel_node.cursor_polar_pos


func _on_resized():
	if wheel_node != null :
		
		#Resize des slot et  de leur marge
		var slot_size = Vector2(self.size.x/(nbr_palette_slot*.5),self.size.x/(nbr_palette_slot*.5))
		var margin_size :Vector2 = slot_size * margin_slot_size
		slot_size -= 2*margin_size
		for slot in grid_node.get_children() :
			slot.self_size = slot_size
		grid_node.add_theme_constant_override("h_separation", int(margin_size.x))
		grid_node.add_theme_constant_override("v_separation", int(margin_size.x))
		
		#Resize de l'espace avec la roue
		$VBoxContainer.add_theme_constant_override("separation", int(self.size.y*.5 * wheel_margin))
		$VBoxContainer/wheel_container.add_theme_constant_override("margin_left",margin_size.x)
		$VBoxContainer/wheel_container.add_theme_constant_override("margin_right",margin_size.x)
		
		#label_node.label_settings.font_size = self.size.x * label_size
