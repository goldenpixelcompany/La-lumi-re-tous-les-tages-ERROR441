extends Control

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color

@onready var FPS_bar_node = $main_container/FPS_BPM/HBoxContainer/FPS_bar

@onready var H_toggle_node= $main_container/Color_balance/HSV/H/MarginContainer/ColorRect
@onready var H_bar_node = $main_container/Color_balance/HSV/H/H_bar
@onready var S_bar_node = $main_container/Color_balance/HSV/S_bar
@onready var V_bar_node = $main_container/Color_balance/HSV/V_bar

@onready var R_bar_node = $main_container/Color_balance/RGB/R_bar
@onready var G_bar_node = $main_container/Color_balance/RGB/G_bar
@onready var B_bar_node = $main_container/Color_balance/RGB/B_bar

var bars_array : Array = []

@onready var control_tl_node = $main_container/TL_command/HBoxContainer

signal tl_input(step:int)
signal play(val:bool)
signal shader_value_change(propriete:String,value:float)

var Midi_Input :Array
var Midi_Thread :Thread

var play_midi_buff :int = 0
var file_size_buff :int = 0

# TCP server, stream des entrées midi Ou pas Hihi
#var tcp_server :TCPServer = TCPServer.new()
#var connection_prise :bool = false
#var stream : StreamPeerTCP
#var data :String = ''

func _ready():
	bars_array.append(FPS_bar_node)
	bars_array.append(H_bar_node)
	bars_array.append(S_bar_node)
	bars_array.append(V_bar_node)
	bars_array.append(R_bar_node)
	bars_array.append(G_bar_node)
	bars_array.append(B_bar_node)
	
	print(bars_array)
	
	FPS_bar_node.FPS_value = 4
	
	H_bar_node.FPS_value = 1.
	S_bar_node.FPS_value = 1.
	V_bar_node.FPS_value = 1.
	
	R_bar_node.FPS_value = 1.
	G_bar_node.FPS_value = 1.
	B_bar_node.FPS_value = 1.
	
	FPS_bar_node.FPS_bar_node._on_resized()
	
	control_tl_node.set_buttons_color(theme_color)
	
	OS.open_midi_inputs()
	
#	OS.open_midi_inputs()
#	print(OS.get_connected_midi_inputs())

	#Initialisation du serveur midi
#	tcp_server.listen(4444,"127.0.0.1")

func _process(delta):
#	if tcp_server.is_connection_available() and not connection_prise :
#		print('connection available')
#		stream = tcp_server.take_connection()
#
#	if stream != null :
#		var read_char :String = ''
#		for i in range(10):
#			read_char = stream.get_string(1)
#			if read_char != ";" :
#				data += read_char
#			else :
#				print(data)
	#if !OS.get_connected_midi_inputs().is_empty() :
		#var midi_input = check_midi_input()
		#if ! (midi_input is bool) : #Une belle opti de shalg qui fonctionne bien bravo
			#update_sliders(int(midi_input[0]),float(midi_input[1])/127.)
#	else :
#		print('no update')
	pass
	
	

func check_midi_input() :
#	var Midi_command_array :Array = []
#	var output :Array 
#	OS.execute(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+'/Midi_input.sh',Midi_command_array,output,true)
#	return output
	var file = FileAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+'/midi_inputs.txt', FileAccess.READ)
	if file.get_length() != file_size_buff :
		file_size_buff = file.get_length()
		var content = file.get_as_text()
		content = content.split('\n')[-2]
		var values :PackedStringArray= content.split(' ')
		while  values[0] != 'controller' :
			values.remove_at(0)
		file.close()
		
		values.remove_at(0)
		values.remove_at(1)
		return values
	else :
		return false
		

func update_sliders(controler :int, value:float) :
	
	var slider_index :Array = ['FPS','H','S','V','R','G','B','set_frame','play']
	if controler != 91 :
		controler = controler%10 -1
		if controler < 7 :
			value = value*bars_array[controler].max_value
#			print('value :',value)
			bars_array[controler].FPS_value = value
		else :
			pass # handle le truc cool set _frame
	else :
		if value != play_midi_buff :
			control_tl_node._on_play_pressed()
			play_midi_buff = value
	
	
#	print('controleur :',controler)
	

func _input(event):
#	if event is InputEventMIDI :
#		_print_midi_info(event)
#	else :
#		print('no midi')
	pass

func _print_midi_info(midi_event: InputEventMIDI):
	print('-------MIDI RECIEVED -------')
	print(midi_event)
	print("Channel " + str(midi_event.channel))
	print("Message " + str(midi_event.message))
	print("Pitch " + str(midi_event.pitch))
	print("Velocity " + str(midi_event.velocity))
	print("Instrument " + str(midi_event.instrument))
	print("Pressure " + str(midi_event.pressure))
	print("Controller number: " + str(midi_event.controller_number))
	print("Controller value: " + str(midi_event.controller_value))
	print('----------------------------------------------------------')

func _on_bar_value_change(propriete :String, value :float) :
	print( propriete, ' : ', value)
	shader_value_change.emit(propriete,value)


func _on_resized():
	pass


func _on_h_toggled_state_change(val :bool):
	if val :
		H_bar_node.input_set = true
		H_bar_node.color_factor = .8
		H_bar_node.set_color(.8)
	else :
		H_bar_node.input_set = false
		H_bar_node.color_factor = .5
		H_bar_node.set_color(.5)
	shader_value_change.emit('H_control',val)


func _on_h_box_container_tl_input(step):
	tl_input.emit(step)


func _on_h_box_container_play_stop_input(playing:bool):
	play.emit(playing)
