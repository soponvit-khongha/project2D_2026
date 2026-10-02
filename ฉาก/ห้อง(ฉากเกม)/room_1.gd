extends Node2D

@export var text_box: CanvasLayer

# 🎯 ดึงโหนดพวงมาลัยใน room_1
@onready var garland: Area2D = get_node_or_null("พวงมาลัย")

func _ready() -> void:
	# 💬 1. เช็กว่าเคยคุยบทพูดแรกในห้องนี้หรือยัง?
	if not GameManager.is_room_talked(name):
		if text_box:
			text_box.queue_text("I have no idea what the hell brought me here.")
			text_box.queue_text("Why the fuck did I come here this late?", "hero", "ยืนเฉยๆ")
			text_box.queue_text("I should head back. Gotta get back to campus.")
			text_box.queue_text("This shrine is creepy as fuck. Wouldn't be this freaky in the morning.")
			text_box.queue_text(".        .         . . ..  .     .")
			text_box.queue_text("If a fucking hand pops out of this shrine, I'm literally gonna have a heart attack.")
			text_box.queue_text("Nah, ain't no way. . . . . . . . What the hell am I thinking? Let's get outta here.")
		
		GameManager.mark_room_as_talked(name)

	# 🌸 2. จัดการระบบการเกิดของพวงมาลัย
	_handle_garland_spawning()

# 🎲 ฟังก์ชันสุ่มการเกิดของพวงมาลัย (1/5)
func _handle_garland_spawning() -> void:
	if not garland:
		return

	# ถ้าเคยเก็บพวงมาลัยไปแล้ว ให้ลบทิ้งทันที
	if GameManager.has_item("garland"):
		garland.queue_free()
		return

	# ถ้าเพิ่งเข้าห้องครั้งแรก (เพิ่งคุยบทพูดแรกจบ) ให้ซ่อนไว้ก่อน
	if not GameManager.is_room_talked("first_visit_done"):
		GameManager.mark_room_as_talked("first_visit_done")
		garland.visible = false
		_set_garland_collision(false)
		return

	# ถ้าเคยย้อนกลับมาและสุ่มเจอไปแล้ว ให้เปิดแสดงตัวตามปกติ
	if GameManager.is_room_talked("garland_spawned"):
		garland.visible = true
		_set_garland_collision(true)
		return

	# 🎯 ถ้าเป็นการย้อนกลับมาครั้งถัดไป ให้ทำการสุ่ม 1 ใน 5
	var chance = randi() % 5
	if chance == 0:
		# สุ่มเจอ! บันทึกไว้ว่าเจอแล้ว + สั่งแสดงตัวพวงมาลัย
		GameManager.mark_room_as_talked("garland_spawned")
		garland.visible = true
		_set_garland_collision(true)
		
		# 💬 เด้งข้อความ ตกใจพวงมาลัย
		if text_box:
			text_box.queue_text("Wait, what the fuck? There definitely wasn't a garland here before...", "hero", "ตกใจ")
	else:
		# สุ่มไม่เจอ ให้ซ่อนไว้
		garland.visible = false
		_set_garland_collision(false)

# 🛠️ ฟังก์ชันปิด/เปิด Collision ของพวงมาลัย
func _set_garland_collision(enabled: bool) -> void:
	if not garland:
		return
	garland.input_pickable = enabled
	garland.monitoring = enabled
	garland.monitorable = enabled
	for child in garland.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", not enabled)
