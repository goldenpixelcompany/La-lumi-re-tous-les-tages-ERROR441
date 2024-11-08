extends Control

@onready var as_node = $animated_preview

func _ready():
	as_node.position = (as_node.scale * 21)*.5 + Vector2(10,5)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
