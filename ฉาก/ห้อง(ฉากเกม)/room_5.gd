extends Node2D

# 🔍 ฟังก์ชันค้นหา TextBox ในฉากปัจจุบัน
func get_text_box() -> Node:
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.find_child("TextBox", true, false)
	return null

func _ready() -> void:
	# 💬 บทพูดเมื่อเข้าห้องครั้งแรก
	if not GameManager.is_room_talked(name):
		var text_box = get_text_box()
		if text_box:
			text_box.queue_text("It smells awful in here...", "hero", "ยืนเฉยๆ")
			text_box.queue_text("...but it feels like something's hidden around here. I should check it out.", "hero", "ยืนเฉยๆ")
			
			GameManager.mark_room_as_talked(name)
