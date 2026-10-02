extends Node2D

var can_input: bool = false

func get_text_box() -> Node:
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.find_child("TextBox", true, false)
	return null

func _ready() -> void:
	# 🔒 เช็กสถานะว่าเคยเข้าห้องนี้รึยัง
	var is_first_time = not GameManager.is_room_talked(name + "_init_done")
	
	if is_first_time:
		# 🔒 ล็อกการกดชั่วคราวก่อนข้อความขึ้น
		can_input = false
		
		# หน่วงเวลาสั้นๆ 1 วินาที
		await get_tree().create_timer(1.0).timeout
		
		# 🔓 ปลดล็อกการกดเพื่อให้ผู้เล่นกดอ่านข้อความได้
		can_input = true
		
		# 💬 รันบทพูดภาษาอังกฤษกวนๆ ชวนกลับบ้าน
		var text_box = get_text_box()
		if text_box:
			text_box.queue_text("Ha! I made it out! In your face, nightmare!")
			text_box.queue_text("Alright, enough sightseeing. Time to go home and eat my body weight in pizza.")
			text_box.queue_text("Let's roll before this place changes its mind.")
		
		# ✅ บันทึกสถานะว่าเข้าห้องนี้ครั้งแรกเรียบร้อยแล้ว
		GameManager.mark_room_as_talked(name + "_init_done")
		
	else:
		# 🔓 ถ้าเคยเข้าแล้ว: เดินผ่านได้ปกติ ไม่มีบทพูดซ้ำ
		can_input = true

# 🖱️ ป้องกันการคลิกช่วงแรก
func _input(event: InputEvent) -> void:
	if not can_input:
		if event is InputEventMouseButton and event.pressed:
			get_viewport().set_input_as_handled()
