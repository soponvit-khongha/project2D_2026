extends Node2D

@export var required_item_id: String = "garland" # 🌸 ID ไอเทมพวงมาลัย

# 🎯 ดึงโหนดในฉาก room_13
@onready var ghost_node: Area2D = get_node_or_null("เอ็มออนิว")
@onready var audio_player: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer")
@onready var text_box: CanvasLayer = get_node_or_null("TextBox")

func _ready() -> void:
	# 🔒 1. กรณี: ยังไม่ได้เก็บพวงมาลัย (เอ็มออนิวไม่โผล่)
	if not GameManager.has_item(required_item_id):
		if ghost_node:
			ghost_node.visible = false
			_enable_ghost_collision(false)
		
		# 💬 ขึ้นข้อความเมื่อเข้ามาครั้งแรก (แบบยังไม่มีเอ็มออนิว)
		if text_box and not GameManager.is_room_talked(name + "_empty"):
			text_box.queue_text("This place is eerily empty... Dammit.")
			text_box.queue_text(". . . . But it feels like something powerful is here.", "hero", "ยืนเฉยๆ")
			text_box.queue_text("I need to get out of this shrine ASAP.")
			GameManager.mark_room_as_talked(name + "_empty")

	# 👻 2. กรณี: เก็บพวงมาลัยมาแล้ว (เอ็มออนิวปรากฏตัวอยู่นิ่งๆ)
	else:
		if ghost_node:
			ghost_node.visible = true
			_enable_ghost_collision(true)
			
		# เล่นเสียงประกอบ (ถ้ามี)
		if audio_player and audio_player.stream:
			audio_player.play(0.0)
			
		# 💬 ขึ้นข้อความตกใจเมื่อเจอเอ็มออนิวครั้งแรก
		if text_box and not GameManager.is_room_talked(name + "_ghost_appeared"):
			text_box.queue_text("Wait, isn't that... Amon-New?!", "hero", "ตกใจ")
			GameManager.mark_room_as_talked(name + "_ghost_appeared")

# 🛠️ ฟังก์ชันเปิด/ปิด Collision ของเอ็มออนิว
func _enable_ghost_collision(enabled: bool) -> void:
	if not ghost_node:
		return
	ghost_node.input_pickable = enabled
	ghost_node.monitoring = enabled
	if "monitorable" in ghost_node:
		ghost_node.monitorable = enabled
	for child in ghost_node.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", not enabled)
