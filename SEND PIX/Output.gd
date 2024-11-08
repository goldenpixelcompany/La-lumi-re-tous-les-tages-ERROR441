extends Control

@onready var as_output :AnimatedSprite2D = $Ouput_animation
var sprite_frames_ressource :SpriteFrames 

@onready var mcl = $"/root/MouseCursorLogic"
var screen_rez : Vector2i 

var playing :bool : set = set_playing
var speed :float : set = set_speed 
var frame_time :float 
var delta_buff :float = 0

var editor_selected_frame :int : set = set_editor_selected_frame

var black_image :Image 

func set_editor_selected_frame(value:int) :
	print('editor selected ',value)
	if value >= sprite_frames_ressource.get_frame_count('default') :
		print('added')
		sprite_frames_ressource.add_frame('default',ImageTexture.create_from_image(black_image))


func set_playing(val :bool) : ##Playing setter
	playing = val
	if val :
		delta_buff = 0
		#play()
#	else :
		#stop()

func set_speed(val :float) : ##Speed setter
	speed = val
	#as_output.speed_scale = val
	frame_time = 1./val

func _ready():
	screen_rez = mcl.screen_rez
	self.get_parent().content_scale_size = screen_rez
	
	sprite_frames_ressource = as_output.sprite_frames
	
	black_image = Image.create(21,21,false,Image.FORMAT_RGBA8)
	black_image.fill(Color.BLACK)
	
	editor_selected_frame = 0
	
	playing = true
	speed = 4

func _process(delta):
	if playing :
		delta_buff += delta
		if delta_buff >= frame_time :
			as_output.frame = (as_output.frame +1)%as_output.sprite_frames.get_frame_count('default')
			delta_buff = delta_buff - frame_time

func delete_frame(index :int) :
	sprite_frames_ressource.remove_frame('default',index)

func update_frame(index :int, img :Image) : ##Met a jour le contenu de la frame n°i vers celui de img (attend l'image déja convertie en Image)
	sprite_frames_ressource.set_frame('default',index,ImageTexture.create_from_image(img))
	
func update_seq(img_seq : Array[Image]) : ##Met à jour le contenu de toute les frames vers celui de img seq, en ajoute si besoin (attend l'image déja convertie en Image)
	var compte :int = 0
	
	for image in img_seq :
		if compte >= sprite_frames_ressource.get_frame_count('default') :
			sprite_frames_ressource.add_frame('default',ImageTexture.create_from_image(image))
		else :
			sprite_frames_ressource.set_frame('default',compte,ImageTexture.create_from_image(image))
		compte += 1
	
	while compte < sprite_frames_ressource.get_frame_count('default') :
		for i in range(compte,sprite_frames_ressource.get_frame_count('default')) :
			sprite_frames_ressource.remove_frame('default',i)
			print(i,' removed')
	

func play() :
	as_output.play()

func stop() :
	as_output.stop()

func set_frame(index :int) : ##Set the frame n°index to display
	as_output.frame = index

func set_shader_parameter(parametre:String, value:float) :
	as_output.material.set_shader_parameter(parametre,value)
	if parametre == 'IPS' :
		speed = value

func _on_tl_input(step:int) :
	if as_output.frame -1 >= 0 :
		as_output.frame = (as_output.frame +step)%as_output.sprite_frames.get_frame_count('default')
	else :
		as_output.frame = as_output.sprite_frames.get_frame_count('default')

func _on_play_stop_input(val :bool) :
	playing = val
