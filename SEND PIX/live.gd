extends Control

var live :bool : set = set_live
@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color

var label_size : float = .8

func set_live (val :bool) :
	if val :
		$HBoxContainer/Label.text = 'LIVE'
		$HBoxContainer/point.color = Color.RED
	else :
		$HBoxContainer/Label.text = 'FREEZE'
		$HBoxContainer/point.color = Color.SLATE_GRAY

func _ready():
	$HBoxContainer/Label.label_settings.font_color = theme_color
	live = true
	_on_resized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_resized():
	if $HBoxContainer/Label != null :
		$HBoxContainer/Label.label_settings.font_size = self.size.y * label_size
		$HBoxContainer/point.custom_minimum_size = Vector2(self.size.y,self.size.y)
		$HBoxContainer/point.size =  Vector2(self.size.y,self.size.y)
