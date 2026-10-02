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
			text_box.queue_text("Whoa, look at this! What a nice find. Looks like it hasn't even been opened yet.", "hero", "ยืนเฉยๆ")
			text_box.queue_text("Hmm... would it be fine if I eat this? The owner probably isn't around here anyway.", "hero", "ยืนเฉยๆ")
			text_box.queue_text("What do you think?", "hero", "ยืนเฉยๆ")
			
			GameManager.mark_room_as_talked(name)
