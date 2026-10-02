extends Area2D

# 🌸 ID ไอเทมพวงมาลัย
@export var required_item_id: String = "garland"
# 🚪 พาธฉากเป้าหมายที่จะวาร์ปไปหลังคุยจบ
@export_file("*.tscn") var target_scene: String = "res://ฉาก/ห้อง(ฉากเกม)/ฉากจบ/ฉากจบ2.tscn"

@export_category("รูปเมาส์")
@export var custom_cursor_texture: Texture2D

@onready var audio_player: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer")
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

var is_hovered: bool = false

# ดึงกล่องข้อความจากฉากปัจจุบัน
func get_text_box() -> Node:
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.find_child("TextBox", true, false)
	return null

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	visible = false
	_enable_area(false)
	
	if GameManager.has_item(required_item_id):
		visible = true
		_enable_area(true)
		
		if audio_player and audio_player.stream:
			audio_player.play(0.0)
			
		if anim_player and anim_player.has_animation("RESET"):
			anim_player.play("RESET")
		else:
			play_ghost_shake()

# 🖱️ ระบบดักจับการคลิกคุย
# 🖱️ แก้ไขส่วนบทพูดและการวาร์ปในฟังก์ชัน _input
# 🖱️ ระบบดักจับการคลิกคุย
func _input(event: InputEvent) -> void:
	if not visible or not is_hovered:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var text_box = get_text_box()
		
		# 🎯 [จุดที่ต้องแก้] เช็กว่ากล่องข้อความกำลังแสดงอยู่ไหม (ป้องกันคลิกเบิ้ลตอนข้อความยังพิมพ์ไม่จบ)
		if text_box:
			var container = text_box.get_node_or_null("MarginContainer") # หรือชื่อโหนดลูกใน TextBox ของคุณ
			if container and container.visible:
				return
		
		# บทพูดประโยคที่ 1
		if not GameManager.is_room_talked("emnaw_dialogue_step1"):
			if text_box:
				text_box.queue_text("You're lucky to have found me. Listen, we don't have much time left.")
			GameManager.mark_room_as_talked("emnaw_dialogue_step1")
			
		# บทพูดประโยคที่ 2
		elif not GameManager.is_room_talked("emnaw_dialogue_step2"):
			if text_box:
				text_box.queue_text("We need to get out of here now, kid.")
			GameManager.mark_room_as_talked("emnaw_dialogue_step2")
			
		# ถ้าคุยครบแล้ว คลิีกอีกทีเพื่อวาร์ปไปฉากจบ 2
		else:
			Input.set_custom_mouse_cursor(null)
			if target_scene != "" and ResourceLoader.exists(target_scene):
				get_tree().change_scene_to_file(target_scene)

# 🫨 ฟังก์ชันสั่นตัว
func play_ghost_shake() -> void:
	var original_pos: Vector2 = position
	var tween: Tween = create_tween()
	for i in range(6):
		var random_offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
		tween.tween_property(self, "position", original_pos + random_offset, 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)

# 🛠️ เปิด/ปิดการทำงานของ Collision
func _enable_area(enabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", not enabled)

# 🖱️ ระบบจัดการรูปเมาส์
func _on_mouse_entered() -> void:
	if not visible:
		return
	is_hovered = true
	if custom_cursor_texture:
		Input.set_custom_mouse_cursor(custom_cursor_texture)

func _on_mouse_exited() -> void:
	is_hovered = false
	Input.set_custom_mouse_cursor(null)
