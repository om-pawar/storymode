extends Node

# Audio Manager: Handles atmospheric monsoon rain, emotional background music, and UI sound effects

var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var current_bgm_track := ""
var current_ambient_track := ""

# Procedural synth parameters for fallback atmospheric sound
var synth_playback: AudioStreamGeneratorPlayback
var ambient_playback: AudioStreamGeneratorPlayback

var is_synthesizing_bgm := false
var is_synthesizing_rain := false

var bgm_phase := 0.0
var chord_notes := [261.63, 329.63, 392.0, 493.88] # C major / A minor romantic chords
var current_chord_index := 0
var chord_timer := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Master"
	add_child(ambient_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)
	
	_setup_procedural_audio()

func _setup_procedural_audio() -> void:
	var gen_bgm := AudioStreamGenerator.new()
	gen_bgm.mix_rate = 22050
	gen_bgm.buffer_length = 0.2
	music_player.stream = gen_bgm
	
	var gen_amb := AudioStreamGenerator.new()
	gen_amb.mix_rate = 22050
	gen_amb.buffer_length = 0.2
	ambient_player.stream = gen_amb

func _process(delta: float) -> void:
	# Keep procedural audio streams filled if active
	if is_synthesizing_bgm and music_player.playing:
		if synth_playback == null:
			synth_playback = music_player.get_stream_playback()
		if synth_playback:
			_fill_bgm_buffer(delta)
			
	if is_synthesizing_rain and ambient_player.playing:
		if ambient_playback == null:
			ambient_playback = ambient_player.get_stream_playback()
		if ambient_playback:
			_fill_rain_buffer(delta)

func _fill_bgm_buffer(delta: float) -> void:
	chord_timer += delta
	if chord_timer > 3.0:
		chord_timer = 0.0
		current_chord_index = (current_chord_index + 1) % 4
		# Switch chords for emotional progression
		match current_chord_index:
			0: chord_notes = [220.0, 261.63, 329.63, 392.0] # Am7 (rainy/nostalgic)
			1: chord_notes = [174.61, 220.0, 261.63, 329.63] # Fmaj7 (warm longing)
			2: chord_notes = [261.63, 329.63, 392.0, 523.25] # C (hopeful)
			3: chord_notes = [196.0, 246.94, 293.66, 392.0] # G (soaring)
	
	var frames_available := synth_playback.get_frames_available()
	var sample_hz := 22050.0
	for i in range(frames_available):
		var sample := 0.0
		for note in chord_notes:
			sample += sin(bgm_phase * note * TAU) * 0.04
		# Soft low-pass feel
		sample += sin(bgm_phase * 110.0 * TAU) * 0.05
		bgm_phase = fmod(bgm_phase + 1.0 / sample_hz, 1.0)
		synth_playback.push_frame(Vector2(sample, sample))

func _fill_rain_buffer(delta: float) -> void:
	var frames_available := ambient_playback.get_frames_available()
	for i in range(frames_available):
		# Filtered white noise for gentle monsoon patter
		var noise := (randf() * 2.0 - 1.0) * 0.035
		ambient_playback.push_frame(Vector2(noise, noise))

func play_bgm(track_name: String) -> void:
	if current_bgm_track == track_name and music_player.playing:
		return
	current_bgm_track = track_name
	
	var track_path := "res://assets/audio/" + track_name + ".ogg"
	if ResourceLoader.exists(track_path):
		var stream := load(track_path)
		music_player.stream = stream
		is_synthesizing_bgm = false
		music_player.play()
	else:
		# Fallback to procedural soothing music
		if not music_player.playing or not is_synthesizing_bgm:
			var gen := AudioStreamGenerator.new()
			gen.mix_rate = 22050
			music_player.stream = gen
			music_player.play()
			synth_playback = music_player.get_stream_playback()
			is_synthesizing_bgm = true

func play_ambient(track_name: String) -> void:
	current_ambient_track = track_name
	var track_path := "res://assets/audio/" + track_name + ".ogg"
	if ResourceLoader.exists(track_path):
		var stream := load(track_path)
		ambient_player.stream = stream
		is_synthesizing_rain = false
		ambient_player.play()
	else:
		# Fallback to procedural rain ambience
		if not ambient_player.playing or not is_synthesizing_rain:
			var gen := AudioStreamGenerator.new()
			gen.mix_rate = 22050
			ambient_player.stream = gen
			ambient_player.play()
			ambient_playback = ambient_player.get_stream_playback()
			is_synthesizing_rain = true

func stop_bgm() -> void:
	is_synthesizing_bgm = false
	music_player.stop()

func stop_ambient() -> void:
	is_synthesizing_rain = false
	ambient_player.stop()

func play_sfx(sfx_name: String) -> void:
	# Procedural simple beeps/chimes for UI responsiveness
	var sfx_stream := AudioStreamGenerator.new()
	sfx_stream.mix_rate = 22050
	sfx_stream.buffer_length = 0.15
	sfx_player.stream = sfx_stream
	sfx_player.play()
	var pb := sfx_player.get_stream_playback()
	if not pb:
		return
	
	var freq := 440.0
	match sfx_name:
		"dialogue_blip": freq = 650.0
		"choice_select": freq = 880.0
		"paper_caught": freq = 1046.5 # C6 bright chime
		"mission_complete": freq = 587.33
		"phone_chime": freq = 987.77
		_: freq = 523.25
	
	var frames: int = pb.get_frames_available()
	var limit: int = min(frames, 3000)
	for i in range(limit):
		var t: float = float(i) / 22050.0
		var envelope: float = max(0.0, 1.0 - (t / 0.12))
		var val: float = sin(t * freq * TAU) * 0.12 * envelope
		pb.push_frame(Vector2(val, val))
