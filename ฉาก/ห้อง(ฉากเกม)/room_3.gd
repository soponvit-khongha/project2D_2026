extends Node2D

@export_file("*.tscn") var next_scene_path: String = "res://ฉาก/ห้อง(ฉากเกม)/room_12.tscn"

# 🎯 ดึงโหนดปุ่มทางเดิน (ใช้ ขวา2 แทน ขึ้นลง)
@onready var btn_up_down: Area2D = get_node_or_null("ขวา2")
@onready var btn_right: Area2D = get_node_or_null("ขวา")

func get_text_box() -> Node:
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.find_child("TextBox", true, false)
	return null

func _ready() -> void:
	# 🔓 ถ้าเคยตรวจประตูไปแล้ว ให้แสดงปุ่มทางเดินทันที
	if GameManager.is_room_talked("checked_room3_door"):
		_show_navigation_buttons()

	# 💬 บทพูดเมื่อเข้าห้องครั้งแรก
	if not GameManager.is_room_talked(name):
		var text_box = get_text_box()
		if text_box:
			text_box.queue_text("Wait, is the exit literally right behind me?")
			text_box.queue_text("Huh, why's it shut? Ain't no way it's locked...", "hero", "ยืนเฉยๆ")
			text_box.queue_text(".....Nah, no way. I'm way too lucky for that, fr.", "hero", "ยืนเฉยๆ")
			text_box.queue_text("Let's go check it out.", "hero", "ยืนเฉยๆ")
			
			GameManager.mark_room_as_talked(name)

# --- ฟังก์ชันสั่งเปิดโหนดทางเดิน ---
func _show_navigation_buttons() -> void:
	var buttons = [btn_up_down, btn_right]
	for btn in buttons:
		if btn:
			btn.show()
			btn.input_pickable = true
			btn.monitoring = true
			btn.monitorable = true
			for child in btn.get_children():
				if child is CollisionShape2D or child is CollisionPolygon2D:
					child.disabled = false

# --- เมื่อกดปุ่ม "ลง" ---
func _on_ลง_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GameManager.has_item("shrine_key"):
			get_tree().change_scene_to_file(next_scene_path)
		else:
			var text_box = get_text_box()
			if text_box:
				var container = text_box.get_node_or_null("MarginContainer")
				if container and container.visible:
					return
					
				if not GameManager.is_room_talked("checked_room3_door"):
					text_box.queue_text("WTF, how is this door locked? Then how the hell did I even get in here?","hero","ยืนเฉยๆ")
					GameManager.mark_room_as_talked("checked_room3_door")
					
					# 🔓 แสดงปุ่มทางเดินทันที!
					_show_navigation_buttons()
				else:
					text_box.queue_text("I gotta find a key to unlock this damn thing.")
