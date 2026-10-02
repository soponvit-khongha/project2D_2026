extends Node2D

# 📌 ดึงโหนดปุ่ม (ถ้าใช้ TextureButton ให้ใช้ $TextureButton / ถ้าใช้ Area2D ให้ใช้ $Area2D)
@onready var play_button = get_node_or_null("TextureButton") 

@export_file("*.tscn") var next_scene_path: String = "res://ฉาก/คัดซีนไปเมน.tscn"

var button_tween: Tween

func _ready() -> void:
	# 🛑 สั่งหยุดเพลงแบ็คกราวด์หลักผ่าน BackgroundMusic
	if has_node("/root/BackgroundMusic"):
		var bgm = get_node("/root/BackgroundMusic")
		
		# ถ้าเพิ่ม stop_music() ใน BackgroundMusic.gd แล้ว สามารถเรียกใช้บรรทัดนี้ได้เลย:
		if bgm.has_method("stop_music"):
			bgm.stop_music()
		# หรือถ้ามีตัวแปร audio_player อยู่ข้างใน:
		elif "audio_player" in bgm and bgm.audio_player:
			bgm.audio_player.stop()

	# 🎵 เล่นเพลงของฉากจบ
	if has_node("เพลง"):
		$เพลง.play()

	# ⚙️ 3. ตั้งค่าปุ่มและเชื่อมสัญญาณ
	if play_button:
		# ถ้าเป็น TextureButton ให้ตั้ง Pivot ไว้ตรงกลาง
		if play_button is Control:
			await get_tree().process_frame
			play_button.pivot_offset = play_button.size / 2
			play_button.pressed.connect(_on_button_pressed)
		
		# เชื่อมสัญญาณเมาส์
		play_button.mouse_entered.connect(_on_button_mouse_entered)
		play_button.mouse_exited.connect(_on_button_mouse_exited)

# --- เมื่อเมาส์ชี้ที่ปุ่ม (ขยายใหญ่ขึ้น) ---
func _on_button_mouse_entered() -> void:
	if play_button:
		if button_tween and button_tween.is_running():
			button_tween.kill()
			
		button_tween = create_tween()
		button_tween.tween_property(play_button, "scale", Vector2(1.15, 1.15), 0.15)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# --- เมื่อเมาส์ออกจากปุ่ม (กลับขนาดเดิม) ---
func _on_button_mouse_exited() -> void:
	if play_button:
		if button_tween and button_tween.is_running():
			button_tween.kill()
			
		button_tween = create_tween()
		button_tween.tween_property(play_button, "scale", Vector2(1.0, 1.0), 0.15)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# --- เมื่อกดปุ่ม (สำหรับ TextureButton) ---
func _on_button_pressed() -> void:
	change_scene()

# --- ดักจับคลิก (กรณีที่ปุ่มเป็น Area2D) ---
func _unhandled_input(event: InputEvent) -> void:
	if play_button is Area2D:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# เช็กว่าเมาส์วางอยู่บน Area2D หรือไม่
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = get_global_mouse_position()
			query.collide_with_areas = true
			var results = space_state.intersect_point(query)
			for result in results:
				if result.collider == play_button:
					change_scene()
					break

func change_scene() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file("res://ฉาก/ห้อง(ฉากเกม)/ฉากจบ/เคดิต/เคดิด.tscn")
