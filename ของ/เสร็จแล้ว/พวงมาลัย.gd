extends Area2D

@export var item_id: String = "garland" # 🌸 ID ไอเทมพวงมาลัย

@export_category("ตั้งค่าฉากถัดไป")
@export_file("*.tscn") var next_scene_path: String = ""

@export_category("รูปเมาส์")
@export var custom_cursor_texture: Texture2D

@onready var audio_stream_player: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer")

var is_hovered: bool = false
var is_collecting: bool = false

var hover_cursor: Texture2D:
	get:
		return custom_cursor_texture

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# ถ้าเคยเก็บไปแล้ว ให้ลบพวงมาลัยทิ้ง
	if GameManager.has_item(item_id):
		queue_free()

func is_textbox_active() -> bool:
	var current_scene = get_tree().current_scene
	if current_scene:
		var text_box = current_scene.find_child("TextBox", true, false)
		if text_box:
			var container = text_box.get_node_or_null("MarginContainer")
			if container and container.visible:
				return true
	return false

func _process(_delta: float) -> void:
	if is_hovered and is_textbox_active():
		Input.set_custom_mouse_cursor(null)

func _on_mouse_entered() -> void:
	if is_textbox_active() or is_collecting:
		return
	is_hovered = true
	if custom_cursor_texture:
		Input.set_custom_mouse_cursor(custom_cursor_texture)

func _on_mouse_exited() -> void:
	is_hovered = false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	
	var results = space_state.intersect_point(query)
	var found_area: Area2D = null
	for result in results:
		if result.collider is Area2D and result.collider != self:
			found_area = result.collider
			break
			
	if found_area and "hover_cursor" in found_area and found_area.hover_cursor:
		Input.set_custom_mouse_cursor(found_area.hover_cursor)
	else:
		Input.set_custom_mouse_cursor(null)

func _unhandled_input(event: InputEvent) -> void:
	if is_textbox_active() or not is_hovered or is_collecting:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_collecting = true
		
		# 1. บันทึกว่าเก็บพวงมาลัยแล้ว
		GameManager.collect_item(item_id)
		
		# 2. คืนค่าเมาส์
		Input.set_custom_mouse_cursor(null)
		
		# 3. เล่นเสียงเก็บของ (ถ้ามี)
		if audio_stream_player and audio_stream_player.stream:
			audio_stream_player.play(0.0)
		
		# 💬 4. แสดงข้อความเตือน และ ซ่อนรูปพวงมาลัย
		var current_scene = get_tree().current_scene
		if current_scene:
			var text_box = current_scene.find_child("TextBox", true, false)
			if text_box:
				text_box.queue_text("It feels like something just changed at the shrine...", "hero", "ยืนเฉยๆ")
				
				# ซ่อนตัวพวงมาลัยทันที เพื่อไม่ให้ภาพลอยค้างตอนอ่านข้อความ
				visible = false
				
				# รอจนกว่าข้อความจะขึ้นแสดงผล
				await get_tree().process_frame
				
				# รอจนกว่าผู้เล่นจะอ่านข้อความจบและกล่องข้อความปิดลง
				while is_textbox_active():
					await get_tree().process_frame
		
		# 5. ย้ายไปฉากถัดไป หรือ ลบตัวเองทิ้ง
		if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
			get_tree().change_scene_to_file(next_scene_path)
		else:
			queue_free()
