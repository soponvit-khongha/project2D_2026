extends Node2D

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
		# 🔒 ถ้าเข้าครั้งแรก: ล็อกการกดชั่วคราวก่อนข้อความขึ้น
		can_input = false
		
		# หน่วงเวลาสั้นๆ 1 วินาทีให้ฉากโหลดสนิท
		await get_tree().create_timer(1.0).timeout
		
		# 🔓 ปลดล็อกการกดเพื่อให้ผู้เล่นกดอ่านข้อความได้
		can_input = true
		
		# 💬 รันบทพูดภาษาอังกฤษกวนๆ เฉพาะครั้งแรกที่เข้าฉาก
		var text_box = get_text_box()
		if text_box:
			text_box.queue_text("What the hell is that thing on the table?")
			text_box.queue_text("Are you blind, or just stupid? It's a pill bottle, obviously.")
			text_box.queue_text("Eh, maybe it's just vitamins. One pill won't kill me... probably.")
			text_box.queue_text("Maybe this will finally give me the guts to face my fears.")
			text_box.queue_text("Let's do this, you piece of junk! LETS GOOOOO!!!!!!")
		
		# ✅ บันทึกว่าเข้าห้องนี้ครั้งแรกเรียบร้อยแล้ว (ครั้งต่อไปจะไม่มีบทพูดนี้โผล่มาอีก)
		GameManager.mark_room_as_talked(name + "_init_done")
		
	else:
		# 🔓 ถ้าเคยเข้าแล้ว: ให้กดเดินผ่านได้เลยตั้งแต่เริ่ม ไม่มีบทพูดกวนๆ ซ้ำ
		can_input = true

# 🖱️ ป้องกันการคลิกช่วง 1 วิแรก
func _input(event: InputEvent) -> void:
	if not can_input:
		if event is InputEventMouseButton and event.pressed:
			get_viewport().set_input_as_handled()
