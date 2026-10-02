extends Node2D

var can_input: bool = false

# 🎯 1. ใส่พาธฉากที่ต้องการไปที่นี่ (ตัวอย่าง: "res://ฉาก2.tscn")
@export_file("*.tscn") var next_scene: String = "res://ฉาก/ห้อง(ฉากเกม)/ฉากจบ/เคดิต/เคดิด.tscn"

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
		
		# 💬 รันบทพูดกวนๆ เรื่องไฟมืด
		var text_box = get_text_box()
		if text_box:
			text_box.queue_text("Bro... who forgot to pay the electricity bill?", "hero", "ยืนเฉยๆ")
			text_box.queue_text("It's so pitch black I can't even see my own future here.")
			text_box.queue_text("If anything jumps out from the dark, I'm throwing hands. Just saying.")
			
			# ⏳ รอจนกว่าข้อความจะอ่านจบและ TextBox ซ่อนลงไป
			while text_box.is_visible_in_tree():
				await get_tree().process_frame
		
		# ✅ บันทึกสถานะว่าเข้าห้องนี้ครั้งแรกเรียบร้อยแล้ว
		GameManager.mark_room_as_talked(name + "_init_done")
		
		# 🚪 เปลี่ยนไปยังฉากถัดไป
		change_to_next_scene()
		
	else:
		# 🔓 ถ้าเคยเข้าแล้ว: เดินผ่านได้ปกติ
		can_input = true

func change_to_next_scene() -> void:
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)

# 🖱️ ป้องกันการคลิกช่วงแรก
func _input(event: InputEvent) -> void:
	if not can_input:
		if event is InputEventMouseButton and event.pressed:
			get_viewport().set_input_as_handled()
