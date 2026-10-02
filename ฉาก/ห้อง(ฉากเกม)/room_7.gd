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
		# 🔒 ถ้าเข้าครั้งแรก: ล็อกการกด
		can_input = false
		
		# 🎵 เล่นเพลง (ครั้งเดียว)
		if audio_player and audio_player.stream:
			audio_player.play(0.0)
		
		# ⏳ รอ 3 วินาที
		await get_tree().create_timer(3.0).timeout
		
		# 🔓 ครบ 3 วิ ปลดล็อกการกด
		can_input = true
		
		# 💬 รันบทพูด
		var text_box = get_text_box()
		if text_box:
			text_box.queue_text("Damn it, why is this so terrifying? Every step I take up, my shoulders feel so heavy.")
			text_box.queue_text("I think I see something ahead.")
			text_box.queue_text("I've got to go check it out. It might be the key.")
		
		# ✅ บันทึกว่าเข้าห้องนี้ครั้งแรกเรียบร้อยแล้ว
		GameManager.mark_room_as_talked(name + "_init_done")
		
	else:
		# 🔓 ถ้าเคยเข้าแล้ว: ให้กดได้เลยตั้งแต่เริ่ม (can_input เป็น true)
		can_input = true

# 🖱️ ป้องกันการคลิกช่วง 3 วิแรก
func _input(event: InputEvent) -> void:
	if not can_input:
		if event is InputEventMouseButton and event.pressed:
			get_viewport().set_input_as_handled()
