extends Node2D

@onready var play_button = $TextureButton

var button_tween: Tween

func _ready():
	# รอ 1 เฟรมให้ Engine คำนวณ Size ของ TextureButton เสร็จก่อนจัด Pivot
	await get_tree().process_frame
	play_button.pivot_offset = play_button.size / 2
	
	# 🛑 สั่งปิด/หยุดเพลงแบ็คกราวด์ตัวกลาง (BackgroundMusic) เฉพาะฉากนี้
	if has_node("/root/BackgroundMusic"):
		var bgm = get_node("/root/BackgroundMusic")
		if bgm.has_node("AudioStreamPlayer"):
			bgm.get_node("AudioStreamPlayer").stop()
	
	# สั่งเล่นเพลงประกอบหน้า Main จากโหนด `$เพลง` ในฉากนี้ตามปกติ
	if has_node("เพลง"):
		$เพลง.play()
# เมื่อเอาเมาส์ไปวางบนปุ่ม (ขยายใหญ่ขึ้น)
func _on_texture_button_mouse_entered():
	if button_tween and button_tween.is_running():
		button_tween.kill()
		
	button_tween = create_tween()
	button_tween.tween_property(play_button, "scale", Vector2(1.15, 1.15), 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# เมื่อเอาเมาส์ออกจากปุ่ม (กลับขนาดเดิม)
func _on_texture_button_mouse_exited():
	if button_tween and button_tween.is_running():
		button_tween.kill()
		
	button_tween = create_tween()
	button_tween.tween_property(play_button, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# เมื่อกดปุ่ม Play
func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ฉาก/คัดซีนไปเมน.tscn")
