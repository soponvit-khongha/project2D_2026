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
			text_box.queue_text("Three paths to explore? Seriously?")
			text_box.queue_text("If I were a key, where would I be?", "hero", "ยืนเฉยๆ")
			text_box.queue_text("Ha, of course! A key's gotta be hiding somewhere among these three paths. I'm sure of it.", "hero", "ยืนเฉยๆ")
			text_box.queue_text("Should we check the middle one first?", "hero", "ยืนเฉยๆ")
			
			GameManager.mark_room_as_talked(name)
