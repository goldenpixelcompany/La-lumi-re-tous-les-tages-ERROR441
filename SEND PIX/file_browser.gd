extends Control

const LED_screen_res = 21

@onready var dir_list_node = $browser/MarginContainer/HBoxContainer/ScrollContainer/dir_list
@onready var frame_node = $browser/frame
@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color

@onready var animated_preview_node = $browser/MarginContainer/HBoxContainer/Preview/animated_preview_control/Control/animated_preview
@onready var list_preview_node = $browser/MarginContainer/HBoxContainer/Preview/list_preveiw/list_preview_flow

var dir_slot_scene = preload("res://dir_slot.tscn")
@export var target_size = Vector2(540,960)
var import_folder_path :String : set = set_import_folder

signal import_dir_selected(img_picture_seq)
var selected_img_seq :Array[Image] = []

var opened :bool = false

var selected_dir_slot :int

func set_import_folder(folder_path :String) :
	import_folder_path = folder_path 
	
	var dir = DirAccess.open(folder_path)
	var folders :PackedStringArray = dir.get_directories()
	
	var compte :int = 0
	for folder in folders :
		var new_dir_slot = dir_slot_scene.instantiate()
		dir_list_node.add_child(new_dir_slot)
		await get_tree().create_timer(0.2).timeout
		new_dir_slot.dir_path = folder_path + '/' + folder
		new_dir_slot.connect("selection_confirmed",_on_selection_confirmed)
		new_dir_slot.connect("slot_selected",unselect)
		new_dir_slot.index = compte
		compte += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$shadow/ColorRect.color = theme_color
	
	var testdir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES))
	if !testdir.get_directories().has('LED_exports') :
		testdir.make_dir('LED_exports')
	import_folder_path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES) + '/LED_exports'
	frame_node.material.set_shader_parameter('theme_color',theme_color)
	frame_node.material.set_shader_parameter('aspect_ratio', self.size.x/self.size.y)
	frame_node.material.set_shader_parameter('alpha',1.)
	frame_node.material.set_shader_parameter('line_thinckness',.007)
	
	#open()


func _input(event):
	var forward :int = 0
	if event is InputEventKey and !event.is_released() and opened :
	
		if event.is_action_pressed('ui_up',true) :
			forward = -1
		elif event.is_action_pressed('ui_down',true) :
			forward = 1
		
		elif event.is_action_pressed('ui_accept') :
			dir_list_node.get_child(selected_dir_slot).confirm()
		
		if selected_dir_slot == null :
			selected_dir_slot = 0
		else :
			selected_dir_slot = (selected_dir_slot+forward) %dir_list_node.get_child_count()
			#print(dir_list_node.get_child_count())
			dir_list_node.get_child(selected_dir_slot)._on_button_mouse_entered()
			dir_list_node.get_child(selected_dir_slot)._on_button_pressed()
	elif event.is_action_pressed("import") :
		self.close()

func _process(delta):
	pass

func _on_selection_confirmed(selected_dir :String) :
	
	import_dir_selected.emit(img_seq_to_img_picture_seq(get_img_seq(get_imgs_path(selected_dir))))
	close()

func unselect(index :int) :
	selected_dir_slot = index
	for child in dir_list_node.get_children() :
		if child.index != index : #Deselectionne tous les slot
			child.selected = false
		else : #Selectionne le slot donné en argument
			var base_dir :String = dir_list_node.get_child(index).dir_path
			var sprite_frames_ressource :SpriteFrames = animated_preview_node.sprite_frames
			
			if not sprite_frames_ressource.get_animation_names().has(base_dir) :
			
				var imgs_path :PackedStringArray = get_imgs_path(base_dir)
				var imgs_seq :Array[Image] = get_img_seq(imgs_path)
			
				sprite_frames_ressource.add_animation(base_dir)
				sprite_frames_ressource.set_animation_speed(base_dir,8.33)
				var compte :int = 0
			
				for image in imgs_seq :
					sprite_frames_ressource.add_frame(base_dir,ImageTexture.create_from_image(image))
					
					
					var new_texture_rect :TextureRect = TextureRect.new()
					new_texture_rect.texture = ImageTexture.create_from_image(image)
					new_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
					list_preview_node.add_child(new_texture_rect)
					new_texture_rect.name = base_dir +'&'+ str(compte)
					new_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					new_texture_rect.custom_minimum_size = Vector2(65,65)

			animated_preview_node.play(base_dir)
			
			for frame_prev in list_preview_node.get_children() :
				#print(frame_prev.name.split("&")[0])
				#print(base_dir)
				selected_img_seq = []
				if frame_prev.name.split("&")[0] == base_dir.replace("/","_") :
					frame_prev.show()
				else :
					frame_prev.hide()

func open() :
	#print('opening')
	opened = true
	self.custom_minimum_size.x = target_size.x
	self.size.x = target_size.x
	self.custom_minimum_size.y = 0
	self.size.y = 0
	var tween = create_tween()
	self.show()
	tween.tween_property(self,"custom_minimu_size:y",target_size.y,.3)
	tween.parallel().tween_property(self,'size:y',target_size.y,.3)

func close() :
	opened = false
	self.custom_minimum_size.x = target_size.x
	self.size.x = target_size.x
	self.custom_minimum_size.y = .0
	self.size.y = target_size.y
	var tween = create_tween()
	tween.tween_property(self,"size:y",1,.3)
	tween.tween_callback(self.hide)

################### IMPORT ###########################


func get_imgs_path(base_dir) -> PackedStringArray :
	var files :PackedStringArray = []
	var dir = DirAccess.open(base_dir)
	
	files = dir.get_files()
	#Tri des fichiers pour éviter certains cas limite (10,20,30...100,200 ectt appears out of order)
	#print("______________FILE RENAME POUR FIX BUG ___________")
	if files.has('0.png') or files.has('0.jpg') :
		#print("Needs renaming")
		for file in files :
			var file_name :String = file.split('.')[0]
			#print('file_name in : ',file_name)
			if file_name.is_valid_int() and file.split('.').size() == 2 :
				if (int(file_name)/10) > 0 :
					if (int(file_name)/100) > 0 :
						if (int(file_name)/1000) > 0 :
							pass
						else :
							file_name = '0' + file_name
					else :
						file_name = '00' + file_name
				else :
					file_name = '000' + file_name
				#print('file_name out : ',file_name)
				dir.rename(file,file_name + '.' +file.split('.')[1])
	#print("______________FIN___________")
	
	#Maj de l'array
	files = dir.get_files()
	
	#Filtrage des non png ou jpg
	var temp_files : PackedStringArray = []
	for i in range (files.size()) :
		files[i] = base_dir + '/' + files[i]
		if not (files[i].ends_with(".png") or files[i].ends_with(".jpg")) :
			pass
		else : 
			temp_files.append(files[i])
	
	#print(temp_files)
	return temp_files


		

func get_img_seq (files_path : PackedStringArray) -> Array[Image] : #files_path contient {path|ends_with(png or jpg)}. Renvois Array[Image] 
	var img_picture_seq : Array[Image] = []

	for file in files_path :
		img_picture_seq.append(load_img(file))
	
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
	if ext_img.get_height() > LED_screen_res :
		var size :int = min(ext_img.get_height(),ext_img.get_width())
		ext_img.crop(size,size)
		ext_img.resize(LED_screen_res,LED_screen_res,Image.INTERPOLATE_TRILINEAR)
	return ext_img

func img_seq_to_img_picture_seq (img_seq :Array[Image]) :
	var img_picture_seq :Array = []
	for img in img_seq :
		img_picture_seq.append(img_picture_from_image(img))
	return img_picture_seq

func img_picture_from_image(ext_img :Image) -> Array[Color] :
	var img_picture : Array[Color]
	for y in range(ext_img.get_height()) :
		for x in range(ext_img.get_width()) :
			img_picture.append(ext_img.get_pixel(x,y))
	return img_picture
