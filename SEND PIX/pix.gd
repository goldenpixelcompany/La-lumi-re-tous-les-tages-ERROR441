extends Control

@onready var colorRect_node = get_node("MarginContainer/White")

signal mouse_entered_pix(pix,pix_index :int)
signal mouse_exited_pix(pix,pix_index :int)

const gris_level_marge :float = .2


var pix_index :int

func _ready():
	colorRect_node.material.set_shader_parameter("gray_value",gris_level_marge)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered() -> void:
	mouse_entered_pix.emit(colorRect_node,pix_index)


func _on_mouse_exited() -> void:
	mouse_exited_pix.emit(colorRect_node,pix_index)

func set_pix_margin(margin :float, aspect_ratio :float) :

	colorRect_node.material.set_shader_parameter('line_thinckness',margin)
	colorRect_node.material.set_shader_parameter('aspect_ratio',1/aspect_ratio)
		

func remove_margin() -> void :
	colorRect_node.material = null
