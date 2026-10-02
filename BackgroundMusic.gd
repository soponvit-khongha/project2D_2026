extends Node

var audio_player: AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

	# เพลงเริ่มต้นของเกม
	var default_music = preload("res://ภาพ/เสียง/wolfdudedodi-asylum-536259.mp3")
	audio_player.stream = default_music
	audio_player.play()

# ฟังก์ชันสำหรับเปลี่ยนเพลงข้ามฉาก
func play_music(new_stream: AudioStream) -> void:
	if audio_player.stream != new_stream:
		audio_player.stream = new_stream
		audio_player.play()
