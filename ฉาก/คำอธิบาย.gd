extends Node2D

@onready var main_label = $ColorRect/RichTextLabel
@onready var skip_button = $TextureButton
@onready var voice_sound = $VoiceSound # ดึงโหนดเสียงมาใช้งาน

# ทำความสะอาดข้อความ ลบอักขระพิเศษที่มักมีปัญหาบนเว็บออกแล้ว
var warning_text = """[center][color=red][b] WARNING / SAFETY NOTICE[/b][/color][/center]

[color=white][CONTENT & PSYCHOLOGICAL WARNING][/color]
This game is a psychological horror experience. It features intentional [color=red][wave amp=30.0 freq=5.0 connected=0]severe jumpscares[/wave][/color], sudden loud sounds, distressing atmosphere, and unsettling imagery.

[color=white][EPILEPSY & PHOTOSENSITIVITY WARNING][/color]
This game contains [color=yellow][wave amp=30.0 freq=5.0 connected=0]flashing lights[/wave][/color], visual distortions, and rapid screen effects. Players with photosensitive epilepsy, heart conditions, or high anxiety should avoid playing.

The developer assumes no responsibility for any shock, distress, or hardware damage.

[center][color=red][b] FINAL WARNING[/b][/color][/center]
- DO NOT... play this game alone.
- DO NOT... play this game in the dark.
- DO NOT... assume you are safe.

[center][i]If you accept the risks... step into the nightmare.[/i][/center]"""

var typing_duration = 18.0
var typing_tween: Tween

func _ready():
	# สำคัญ: ต้องเปิดใช้งาน bbcode_enabled ในการตั้งค่าของ RichTextLabel ด้วย
	main_label.bbcode_enabled = true
	
	skip_button.pivot_offset = skip_button.size / 2
	skip_button.hide()
	
	main_label.text = warning_text
	main_label.visible_characters = 0
	
	start_typing_description()


func start_typing_description():
	var parsed_text = main_label.get_parsed_text()
	var total_chars = parsed_text.length()
	var char_delay = typing_duration / max(total_chars, 1)
	
	main_label.visible_characters = 0
	
	for i in range(total_chars):
		main_label.visible_characters = i + 1
		
		# เล่นเสียงเฉพาะเมื่อไม่ใช่ช่องว่าง/ขึ้นบรรทัดใหม่
		if voice_sound and voice_sound.stream:
			if parsed_text[i] != " " and parsed_text[i] != "\n":
				# สั่งเล่นเสียงแบบซ้ำได้อย่างเป็นธรรมชาติ
				voice_sound.pitch_scale = randf_range(0.95, 1.05)
				voice_sound.play()
		
		await get_tree().create_timer(char_delay).timeout
	
	# เมื่อพิมพ์จบ ให้หยุดเสียงและแสดงปุ่ม Skip (รวมโค้ดที่ซ้ำกันให้สะอาดเรียบร้อย)
	if voice_sound:
		voice_sound.stop()
	skip_button.show()

# ==========================================
#  โค้ดปุ่ม SKIP 
# ==========================================

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ฉาก/ห้อง(ฉากเกม)/room_1.tscn")

func _on_texture_button_mouse_entered():
	var tween = create_tween()
	tween.tween_property(skip_button, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_texture_button_mouse_exited():
	var tween = create_tween()
	tween.tween_property(skip_button, "scale", Vector2(1.0, 1.0), 0.15)
