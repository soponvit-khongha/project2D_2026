extends Node2D

@onready var text_box = $TextBox
# 📌 ดึงโหนดกระดาษเข้ามา (ปรับ Path ให้ตรงกับโหนดกระดาษใน Scene room2 ของคุณ)
@onready var paper = $"กระดาษเช็ดตูด" 

# 📌 ใส่ Path ของ Scene ถัดไปที่ต้องการให้ย้ายไป
@export_file("*.tscn") var next_scene_path: String = "res://room_3.tscn" 

var has_shown_first_text: bool = false # เช็กว่าขึ้นข้อความครั้งแรกไปหรือยัง

func _ready() -> void:
	# บทพูดเริ่มต้นเมื่อเข้าห้องครั้งแรก
	if not GameManager.is_room_talked(name):
		text_box.queue_text("Whoa, the view is actually pretty nice here. Setting up a tent and camping here would be sick.")
		text_box.queue_text("Why do I feel like there's something inside that shrine, though?", "hero", "ยืนเฉยๆ")
		text_box.queue_text("Whatever, I'm starving. Wonder what I should grab to eat later.", "hero", "ยืนเฉยๆ")
		text_box.queue_text("Huh, what's that piece of paper over there?")
		text_box.queue_text("Looks super old. Wonder what it says. Should I pick it up and read it?")
		
		GameManager.mark_room_as_talked(name)
	
	# เชื่อมสัญญาณจากกระดาษเข้ามาที่ห้อง
	if paper:
		paper.paper_closed.connect(_on_paper_closed)

func _on_paper_closed(count: int) -> void:
	# 1. ปิดครั้งที่ 1: แสดงข้อความครั้งแรกครั้งเดียว
	if count == 1 and not has_shown_first_text:
		has_shown_first_text = true
		text_box.queue_text("Oh damn, I hit the jackpot! This is a straight-up hidden gem.")
		text_box.queue_text("Literally all about Larb.")
		text_box.queue_text("Alright, let's keep looking for the exit.","hero","ยืนเฉยๆ")
	# 2. ปิดมากกว่า 4 ครั้ง (ครั้งที่ 5): แสดงข้อความเตือน
	elif count == 5:
		text_box.queue_text("Dude, are you seriously obsessed with Larb all day? Stop reading already!")
		text_box.queue_text("If you open it one more time, something bad is gonna happen... Ugh, I'm getting weird goosebumps.")
	
	# 3. ปิดครั้งที่ 6 (กดเปิด-ปิดอีกครั้งหลังจากเตือน): เปลี่ยนฉากทันที
	elif count >= 6:
		change_to_next_scene()

func change_to_next_scene() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file("res://ฉาก/ห้อง(ฉากเกม)/ฉากจบ/ฉากจบ1.tscn")
