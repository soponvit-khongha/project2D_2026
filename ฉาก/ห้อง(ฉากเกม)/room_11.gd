extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
var can_input: bool = false

func get_text_box() -> Node:
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.find_child("TextBox", true, false)
	return null

func _ready() -> void:
	# 🔒 เช็กสถานะว่าเคยเข้าห้องนี้รึยัง (ใช้ชื่อห้องเป็นคีย์)
	var is_first_time = not GameManager.is_room_talked(name + "_init_done")
	
	if is_first_time:
		# 🔒 ถ้าเข้าครั้งแรก: ล็อกการกดชั่วคราวระหว่างรอเล่นเพลงหรือเปิดฉาก
		can_input = false
		
		# 🎵 เล่นเพลง (ครั้งเดียว)
		if audio_player and audio_player.stream:
			audio_player.play(0.0)
		
		# (ถ้าต้องการหน่วงเวลาก่อนข้อความขึ้น สามารถปรับตรงนี้ได้ หรือเอาออกถ้าจะให้ข้อความขึ้นทันที)
		await get_tree().create_timer(1.0).timeout
		
		# 🔓 ปลดล็อกการกดเพื่อให้ผู้เล่นกดอ่านข้อความได้
		can_input = true
		
		# 💬 รันบทพูดเฉพาะครั้งแรก
		var text_box = get_text_box()
		if text_box:
			text_box.queue_text("Free at last! If I have to go through that again, I'd rather eat my own shoes.")
		
		# ✅ บันทึกว่าเข้าห้องนี้ครั้งแรกเรียบร้อยแล้ว
		GameManager.mark_room_as_talked(name + "_init_done")
		
	else:
		# 🔓 ถ้าเคยเข้าแล้ว: ให้กดได้เลยตั้งแต่เริ่ม ไม่มีเพลง ไม่มีข้อความ
		can_input = true

# 🖱️ ป้องกันการคลิกช่วงแรก (ถ้ามีหน่วงเวลา)
func _input(event: InputEvent) -> void:
	if not can_input:
		if event is InputEventMouseButton and event.pressed:
			get_viewport().set_input_as_handled()
