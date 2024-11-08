extends Control

var tracklist = []
var trackpath = []
var music_path = "res://musique/"

var playing_music_index :int = 0 :set = set_playing_music

@onready var theme_color = $"/root/MouseCursorLogic".general_theme_color

@onready var player_node = $AudioStreamPlayer
@onready var bar_node = $HBoxContainer/bar
@onready var label_node = $HBoxContainer/Label

@export var label_size :float = .03

var play_position_buf :float = 0.

var custom_music_path

func set_playing_music(index:int) :
	if tracklist.size() != 0 :
		index = index%tracklist.size()
		playing_music_index = index
		player_node.stream = tracklist[index]
		#player_node.play()
		label_node.ticker_text = trackpath[index].left(-4).to_upper() + "       "
		print(index)
	else :
		label_node.ticker_text = "PAS DE FICHIERS .MP3 DANS LE DOSSIER /LED_MUSIC     "
	
func _ready():
	
	label_node.label_settings.font_color = theme_color
	_on_resized()
	#play_from(.9)
	
	#Ajout des musiques de l'utilisateur (pour la version exportée)
	if !OS.has_feature("editor") :
		print("not editor")

		if OS.has_feature("linux") :
			custom_music_path = OS.get_executable_path().get_base_dir()
		else :
			custom_music_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		print(custom_music_path)
		var dir = DirAccess.open(custom_music_path)
		print("dir open")
		if !dir.dir_exists("LED_Music") :
			dir.make_dir("LED_Music")
			print("Led musique cerated")
		else :
			print("path exists")
			trackpath = get_music_files(custom_music_path+"/LED_Music",true)
			for path in trackpath :
				var audio_stream
				if path.ends_with('mp3') :
					audio_stream = AudioStreamMP3.new()
					audio_stream = load_mp3(custom_music_path+"/LED_Music/"+path)
					tracklist.append(audio_stream)
	else :
		print("editor")
		trackpath = get_music_files(music_path,false)
		for path in  trackpath:
			print(path)
			tracklist.append(load(music_path+path))
	
	playing_music_index = 0
	
	if !OS.has_feature("editor") :
		$Timer.start()

func _process(delta):
	if player_node.playing :
		bar_node.progress_ratio = get_track_progress()
		#print(get_track_progress())



func get_music_files(path, non_editor :bool):
	print("get_music called with paht : ", path)
	var files :PackedStringArray = []
	var dir = DirAccess.open(path)
	print("dir_opened")
	
	files = dir.get_files()
	print("files_gathered")
	print("files : ",files)
	for file in files :
		if !(file.ends_with('ogg') or file.ends_with('mp3') or file.ends_with('wav')) :
			print(file, "removed")
			files.remove_at(files.rfind(file))
		elif non_editor and not file.ends_with('mp3') :
			print(file, "removed")
			files.remove_at(files.rfind(file))
	
	print(files)
	return files

func _on_audio_stream_player_finished():
	playing_music_index += 1

func get_track_progress() :
	var track_len :float = player_node.stream.get_length()
	var progress : float = player_node.get_playback_position()
	return progress/track_len

func play_from(ratio :float) :
	var track_len :float = player_node.stream.get_length()
	ratio = clamp(.0,ratio,1.)
	player_node.play(track_len*ratio)

func set_volume(ratio :float) :
	player_node.volume_db = (1-ratio) * -80




func _on_bar_clicked(ratio :float):
	play_from(ratio)


func _on_button_pressed(index :int):
	if index == 0 :
		if player_node.playing :
			play_position_buf = player_node.get_playback_position()
			player_node.stop()
		else :
			player_node.play(play_position_buf)
	else : 
		playing_music_index = max(0,playing_music_index + index)
		play_position_buf = .0

func _on_resized():
	if label_node != null :
		label_node.label_settings.font_size = self.size.x * label_size


func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound


func _on_timer_timeout():
	var temp_trackpath = get_music_files(custom_music_path+"/LED_Music",true)
	print("comparaison array : ", compare_array(temp_trackpath,trackpath))
	if !compare_array(temp_trackpath,trackpath) :
		trackpath = temp_trackpath
		for path in trackpath :
			var audio_stream
			if path.ends_with('mp3') :
				audio_stream = AudioStreamMP3.new()
				audio_stream = load_mp3(custom_music_path+"/LED_Music/"+path)
				tracklist.append(audio_stream)
		playing_music_index = 0
	else :
		print("pas de changements de fichiers")
	
	$Timer.start()

func compare_array(array1,array2) :
	print(array1.size())
	if array1.size() == array2.size() :
		for i in range(array1.size()) :
			if array1[i] != array2[i] :
				return false
		return true
	else :
		return false
			
