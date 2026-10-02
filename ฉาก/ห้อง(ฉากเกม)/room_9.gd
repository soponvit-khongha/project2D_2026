extends Node2D

@export_file("*.tscn") var target_scene: String = "res://ฉาก/ห้อง(ฉากเกม)/room_16.tscn"

# 🎯 ดึงโหนด "ลง2" ตามชื่อใหม่ใน Scene Tree ของคุณ
@onready var btn_down2: Area2D = get_node_or_null("ลง2")
@onready var ghost_sprite: CanvasItem = $CanvasLayer/GhostSprite
@onready var audio_stream_player: AudioStreamPlayer = $CanvasLayer/AudioStreamPlayer

var has_jumpscared: bool = false

func get_text_box() -> Node:
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.find_child("TextBox", true, false)
	return null

func _ready() -> void:
	# 🔓 เปิดใช้งานโหนด "ลง2" ให้พร้อมรับคลิกแบบเดียวกับ Room 3
	if btn_down2:
		btn_down2.input_pickable = true
		btn_down2.monitoring = true
		btn_down2.monitorable = true
		for child in btn_down2.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.disabled = false
				
		# ผูกสัญญาณ input_event เข้ากับฟังก์ชันด้านล่างอัตโนมัติ
		if not btn_down2.input_event.is_connected(_on_ลง2_input_event):
			btn_down2.input_event.connect(_on_ลง2_input_event)

# --- เมื่อคลิกโดนโหนด "ลง2" จริงๆ เท่านั้นถึงจะทำงาน ---
func _on_ลง2_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if has_jumpscared:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# 1. เช็กว่าได้ไอเทมผ่านทางหรือยัง
		var has_medicine = GameManager.has_item("medicine")
		var has_energy_drink = GameManager.has_item("energy_drink")
		
		if has_medicine or has_energy_drink:
			get_tree().change_scene_to_file(target_scene)
		else:
			var text_box = get_text_box()
			if text_box:
				var container = text_box.get_node_or_null("MarginContainer")
				if container and container.visible:
					return
			
			# 2. ระบบพูดเตือนตามสเต็ป
			if not GameManager.is_room_talked("checked_room16_step1"):
				if text_box:
					text_box.queue_text("Bro, I swear we shouldn't go down there. That shit looks sketchy as hell.")
				GameManager.mark_room_as_talked("checked_room16_step1")
				
			elif not GameManager.is_room_talked("checked_room16_step2"):
				if text_box:
					text_box.queue_text("Maybe we should look around and check out the area first?")
				GameManager.mark_room_as_talked("checked_room16_step2")
				
			elif not GameManager.is_room_talked("checked_room16_step3"):
				if text_box:
					text_box.queue_text("Just go check somewhere else already, man!")
				GameManager.mark_room_as_talked("checked_room16_step3")
				
			else:
				# 3. 💥 เตือนครบแล้ว กดซ้ำ -> Jumpscare ทำงาน!
				trigger_jumpscare()

# ฟังก์ชันเล่นฉาก Jumpscare
func trigger_jumpscare() -> void:
	has_jumpscared = true
	Input.set_custom_mouse_cursor(null)
	
	if audio_stream_player:
		audio_stream_player.play()
	
	if ghost_sprite:
		ghost_sprite.visible = true
		play_ghost_shake()
		
	await get_tree().create_timer(2.0).timeout
	if ghost_sprite:
		ghost_sprite.visible = false

# ฟังก์ชันทำภาพผีสั่น
func play_ghost_shake() -> void:
	if not ghost_sprite:
		return
	var original_pos: Vector2 = ghost_sprite.position
	var tween: Tween = create_tween()
	for i in range(6):
		var random_offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
		tween.tween_property(ghost_sprite, "position", original_pos + random_offset, 0.05)
	tween.tween_property(ghost_sprite, "position", original_pos, 0.05)
