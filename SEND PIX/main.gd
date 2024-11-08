extends Control

# Valeurs pour exports 16:9 : vbox Music player .07 puis dans hbox 1,2,1 

var LED_screen_res :int = 5

var XYLED_screen_res : Vector2i = Vector2i(21,21) ## Resolution de l'ecran de LED de l'installation

var bucket_mode :bool = false
var selected_color :Color : get = get_selected_color

func get_selected_color() :
	return outils_node.selected_color

@onready var outils_node = $MarginContainer/VBoxContainer/HBoxContainer/Tools_margin/VBoxContainer/Outils
@onready var main_frame_node = $MarginContainer/VBoxContainer/HBoxContainer/Frame_margin/Frame
@onready var tl_node = $MarginContainer/VBoxContainer/HBoxContainer/TL_margin/VBoxContainer/TL
@onready var tl_control_buttons_node = $MarginContainer/VBoxContainer/HBoxContainer/TL_margin/VBoxContainer/TL_control_buttons
@onready var frame_margin_node = $MarginContainer/VBoxContainer/HBoxContainer/Frame_margin
@onready var thx_screen_node = $Thx_screen
@onready var file_browser_node = $file_browser

@onready var live_node = $MarginContainer/VBoxContainer/HBoxContainer/Tools_margin/VBoxContainer/MarginContainer/Live

@onready var output_window = $Output_Screen
@onready var output_node = $Output_Screen/Output

@onready var mcl = $"/root/MouseCursorLogic"

var selected_frame_index :int = 0 : set = set_selected_frame_index
var mouse_clicked

var output_update :bool = false

func set_selected_frame_index(value :int) :
	selected_frame_index = value
	main_frame_node.whipe_state_stack()

var undo_cursor :int = -1

func _ready():
	XYLED_screen_res = mcl.screen_rez 
	
	frame_margin_node.size_flags_stretch_ratio = 2 + float(XYLED_screen_res.x)/float(XYLED_screen_res.y)
	
	await get_tree().create_timer(0.1).timeout
	main_frame_node.set_pix_margin(false)
	main_frame_node.main = true #Indique à l'instance frame qu'elle est la frame au centre de l'écran (et pas noeud enfant de FrameUI)
	
	#print("____________________ IMPORT TEST _________________________")
	#import_test()
	#print("__________________________________________________________")
	
func _input(event):
	if event is InputEventMouseButton :
		if event.button_mask == MOUSE_BUTTON_RIGHT :
			if event.is_pressed() :
				bucket_mode = !bucket_mode
				print('bucket mode : ',bucket_mode)
	elif event.is_action_pressed("ui_undo") :
		undo()
	elif event.is_action_pressed("import") :
		print('import')
		file_browser_node.open()
		pass
		
	elif event.is_action_pressed("Freeze") :
		output_update = !output_update
		if output_update :
			print('Live')
			output_update_all()

		else :
			print("Freeze")
		live_node.live = output_update


func _process(delta):
	#print(get_viewport().size)
	#Highlight le texte "Image" ou 'Outils" en fonction de la position de la souris
	pass

func _on_tl_control_buttons_tl_input(tl_change,is_playing):
	selected_frame_index += tl_change
	selected_frame_index = tl_node.select_frame(selected_frame_index,is_playing)


func _on_tl_changed_selected_frame(frame,index):
	main_frame_node.set_frame_picture(frame.get_frame_picture())
	selected_frame_index = index
	
	#Update Output
	if output_update :
		output_node.editor_selected_frame = selected_frame_index

func _on_frame_pixel_clicked(pix_color, pix_index):
	undo_cursor = -1
	if bucket_mode :
		tl_node.selected.set_frame_picture(bucket_fill(selected_color,main_frame_node.get_frame_picture(),pix_index))
	else :
		main_frame_node.set_frame_picture_pix(selected_color,pix_index)
		tl_node.selected.set_frame_picture_pix(selected_color,pix_index)
	
	#Update output
	if output_update :
		output_node.update_frame(selected_frame_index,img_from_img_picture(tl_node.selected.get_frame_picture()))

################## Fonctions de remplissage de forme ############

func bucket_fill(to_color :Color, frame_picture :Array[Color], input_index :int) :
	var input_color :Color = frame_picture[input_index]
	var pix_filled :Array[int]= [input_index]
	frame_picture[input_index] = to_color
	
	var frame_picture_changed :bool = true

	while frame_picture_changed :
		frame_picture_changed = false
		for i in range(frame_picture.size()) :
			if !pix_filled.has(i) : #Si le pixel n'est pas déjà fill (par cette fonction)
				if frame_picture[i] == input_color : #Si le pixel est de la bonne couleur
					if has_filled_neighboors(i,pix_filled) : # Et Si un des voisin est filled
						frame_picture[i] = to_color
						pix_filled.append(i)
						frame_picture_changed = true
		main_frame_node.set_frame_picture(frame_picture)
		#await get_tree().create_timer(0.066).timeout
	
	#print('end fill')
	return frame_picture

func get_pix_neighboors_index(pix_index :int) -> Array[int] :
	
	var neighboors :Array[int] 
	
	if (pix_index+1)%XYLED_screen_res.x != 0 :
		neighboors.append(pix_index+1)
	if (pix_index-1)%XYLED_screen_res.x != (XYLED_screen_res.x-1) :
		neighboors.append(pix_index-1)
	if (pix_index-XYLED_screen_res.x) > 0 :
		neighboors.append(pix_index-XYLED_screen_res.x)
	if (pix_index+XYLED_screen_res.x)/XYLED_screen_res.x < XYLED_screen_res.y:
		neighboors.append(pix_index+XYLED_screen_res.x)
	
	return neighboors

func has_filled_neighboors(index :int, pix_filled_array :Array[int]) -> bool :
	for neighboor_index in get_pix_neighboors_index(index) :
		if neighboor_index in pix_filled_array :
			return true
	return false
	
	
##############################

func _on_color_selection_color_selected_change(new_color):
	selected_color = new_color


func _on_tl_update_ghost(ghost_frame_picture):
	await get_tree().create_timer(0.005).timeout
	main_frame_node.set_ghost_frame(ghost_frame_picture)

############## Export ################

func export(user_name :String) :
	var animation_pictures = tl_node.get_frame_picture_sequence()
	var img = Image.create(XYLED_screen_res.x,XYLED_screen_res.y,false,Image.FORMAT_RGBA8)
	var frame_compte :int = 0
	
	var save_path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES) + '/LED_exports'
	var pictures
	if !OS.has_feature("editor") :
		if OS.has_feature("linux") :
			pictures = OS.get_executable_path().get_base_dir()
		else :
			pictures = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		var pic_dir = DirAccess.open(pictures)
		if !pic_dir.dir_exists("LED_exports") :
			pic_dir.make_dir("LED_exports")
		
		save_path = pictures + "/LED_exports"
	
	var dir = DirAccess.open(save_path)
	dir.make_dir(user_name)
	
	for pic in animation_pictures :
		for i in range(len(pic)) :
			img.set_pixelv(index_to_coordinate(i),pic[i])
		
		img.save_png(save_path+"/"+user_name+"/"+str(frame_compte)+".png")
		frame_compte += 1


func index_to_coordinate(indx :int) :
	return Vector2i(indx%XYLED_screen_res.x,indx/XYLED_screen_res.x)
	


func _on_export_export(user_name):
	thx_screen_node.start_show()
	thx_screen_node.show()
	export(user_name)



func _on_tl_frame_deleted(index):
	tl_node.select_frame(max(0,selected_frame_index-1))

############ Séried de fonction pour le ctrl+Z ###################

func undo() : ## Further improvement : Rendre le buffer propre a chaque frame, et le recharger a chaque changement de frame, plutôt que le reset
	var frame_picture_to_restore 
	if is_undoable() :
		frame_picture_to_restore = main_frame_node.state_stack[undo_cursor]
		main_frame_node.set_frame_picture(frame_picture_to_restore)
		tl_node.selected.set_frame_picture(frame_picture_to_restore)
		
		if selected_frame_index >0 : #Si nécessaire, re-afichage de la ghost-frame
			main_frame_node.set_ghost_frame(tl_node.get_frame(selected_frame_index-1).get_frame_picture())
		
		undo_cursor -= 1

func redo() :
	pass

func is_undoable() :
	return(abs(undo_cursor)<= len(main_frame_node.state_stack))

func is_redoable() :
	return(abs(undo_cursor) < -1)

func _on_frame_new_input_start(): ##Appeller lorsque l'utilisateur commence une série d'input sur la frame principale (i.e dessine/fill)
	main_frame_node.state_stack.append(tl_node.selected.get_frame_picture()) #Ajoute l'etat actuelle de la frame à la pile d'état, depuis la timeline (pour ne pas prendre en compte la ghost frame)


### Petites fonctions d'utilité générale

func _on_tl_tl_clearing():
	tl_control_buttons_node.play =false


func is_mouse_in_object(object) :
	return Rect2(object.position, object.size).has_point(get_local_mouse_position())


func _on_main_margin_container_resized():
	if frame_margin_node != null :
		frame_margin_node.size_flags_stretch_ratio = 2 + float(XYLED_screen_res.x)/float(XYLED_screen_res.y)
		main_frame_node.set_pix_margin(false)

func _on_outils_tool_selected(tool_index):
	if tool_index == 0 :
		bucket_mode = false
	if tool_index == 1 :
		bucket_mode = true


###################### Fontions d'importation d'image ###################


func import() :
	pass
	#Pseudo code :
	#clear TL
	#ask for dir
	#var files = get_imgs_path(dir)
	# if !files.is_empty :
	#	var img_picture_seq = get_img_seq(files)
	#	for i in range(len(file))
	#		create_frame
	#		created_frame.set_img_picture(img_picture_seq[i])

func import_test() : ##Fcontions de test de l'importation 
	var files = get_imgs_path(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)+"/LED_exports/TEST")
	print(get_img_seq(files))
	
	
func get_imgs_path(base_dir) -> PackedStringArray :
	var files :PackedStringArray = []
	var dir = DirAccess.open(base_dir)
	
	files = dir.get_files()
	var temp_files : PackedStringArray = files
	for i in range (files.size()) :
		files[i] = base_dir + '/' + files[i]
		if not (files[i].ends_with(".png") or files[i].ends_with(".jpg")) :
			temp_files.remove_at(i)
	files = temp_files
	print(files)
	return files

func get_img_seq (files_path : PackedStringArray) : #files_path contient {path|ends_with(png or jpg)}. Renvois Array[Array[Color]] (img_picture, classe non formalisée utilisée pour l'affichage d'une image dans Frame)
	var img_picture_seq : Array = []

	for file in files_path :
		img_picture_seq.append(img_picture_from_image(load_img(file)))
	
	return img_picture_seq

func load_img(path :String) -> Image :
	var file = FileAccess.open(path, FileAccess.READ)
	var img = Image.new()
	print(path)
	#Chargement du fichier selon son format
	if path.ends_with(".png") :
		img.load_png_from_buffer(file.get_buffer(file.get_length()))
	elif path.ends_with(".jpg") :
		img.load_jpg_from_buffer(file.get_buffer(file.get_length()))
	
	#Mise à l'échelle de l'image (crop(not centered) + resize)
	img = resize_ext_img(img)
	
	return img

func resize_ext_img(ext_img : Image) -> Image : ## Crop et resize l'image, non centrée. TBI : crop centré en utilisant Image.get_region. 
	if ext_img.get_height() > XYLED_screen_res.y or ext_img.get_width() > XYLED_screen_res.x :
		var extratio :float = ext_img.get_width()/ext_img.get_height()
		var intratio : float = float(XYLED_screen_res.x)/float(XYLED_screen_res.y)
		if extratio >= intratio :
			ext_img.crop(ext_img.get_height()*intratio,ext_img.get_height())
		else :
			ext_img.crop(ext_img.get_width(),ext_img.get_width()/intratio)
		ext_img.resize(XYLED_screen_res.x,XYLED_screen_res.y,Image.INTERPOLATE_TRILINEAR)
	return ext_img

func img_picture_from_image(ext_img :Image) -> Array[Color] :
	var img_picture : Array[Color]
	for y in range(ext_img.get_height()) :
		for x in range(ext_img.get_width()) :
			img_picture.append(ext_img.get_pixel(x,y))
	print( "img picture : ",img_picture)
	return img_picture

func img_from_img_picture(img_pic :Array[Color]) -> Image :
	var img = Image.create(XYLED_screen_res.x,XYLED_screen_res.y,false,Image.FORMAT_RGBA8)
	for i in range(img_pic.size()) :
		img.set_pixelv(index_to_coordinate(i),img_pic[i])
	return img

func _on_file_browser_import_dir_selected(img_picture_seq):
	var compte :int = 0
	var frame_compte :int = tl_node.grid_node.get_child_count() - 1 
	print('frame_compte ',frame_compte)
	print(img_picture_seq.size())
	
	var img_seq_output :Array[Image] = []

	
	for img_picture in img_picture_seq :
		if compte < frame_compte :
			tl_node.get_frame(compte).set_frame_picture(img_picture)
		else :
			await tl_node._on_add_frame_pressed()
			tl_node.get_frame(compte).set_frame_picture(img_picture)
		img_seq_output.append(img_from_img_picture(img_picture))
		compte += 1
		
	if output_update :
		output_node.update_seq(img_seq_output)
	
	#Suppression des images en trop
	if compte < frame_compte :
		for i in range(compte,frame_compte) :
			tl_node.delete_frame(i)

func output_update_all() :
	var img_seq_output :Array[Image] = []
	var img_pic_seq = tl_node.get_frame_picture_sequence()
	for img_pic in img_pic_seq :
		img_seq_output.append(img_from_img_picture(img_pic))
	output_node.update_seq(img_seq_output)
