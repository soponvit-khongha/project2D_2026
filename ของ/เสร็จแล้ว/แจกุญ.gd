extends Area2D

@export var item_id: String = "shrine_key" # หรือ "shrine_key"

@export_category("รูปเมาส์")
@export var custom_cursor_texture: Texture2D

@onready var audio_stream_player: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer")

var is_hovered: bool = false

# ให้สคริปต์อื่น (หรือ Raycast) เรียกดูรูปเมาส์ของไอเทมนี้ได้ง่ายๆ
var hover_cursor: Texture2D:
	get:
		return custom_cursor_texture

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# ถ้าเคยเก็บไปแล้ว ให้ลบทิ้งทันทีตั้งแต่เริ่มโหลดฉาก
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
	# ถ้ากำลังเปิด TextBox อยู่ให้รีเซ็ตเมาส์เป็นปกติ
	if is_hovered and is_textbox_active():
		Input.set_custom_mouse_cursor(null)

func _on_mouse_entered() -> void:
	if is_textbox_active():
		return
	is_hovered = true
	if custom_cursor_texture:
		Input.set_custom_mouse_cursor(custom_cursor_texture)

func _on_mouse_exited() -> void:
	is_hovered = false
	
	# ยิง Raycast/Point เช็กว่าตำแหน่งเมาส์ตอนนี้ยังลอยอยู่บน Area2D อื่นหรือไม่
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
		# ถ้าถอยเมาส์ออกแล้วเจอ Area2D ตัวอื่นข้างใต้ -> ให้สลับไปใช้รูปเมาส์ของตัวนั้นทันที
		Input.set_custom_mouse_cursor(found_area.hover_cursor)
	else:
		# ถ้าถอยออกไปเจอพื้นที่ว่างเปล่า -> คืนเป็นเมาส์ปกติ
		Input.set_custom_mouse_cursor(null)

func _unhandled_input(event: InputEvent) -> void:
	if is_textbox_active() or not is_hovered:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if audio_stream_player and audio_stream_player.stream:
			audio_stream_player.play(0.0)
			
		# เก็บไอเทมลง GameManager
		GameManager.collect_item(item_id)
		
		# คืนค่าเมาส์เป็นปกติก่อนลบโหนด
		Input.set_custom_mouse_cursor(null)
		
		# ลบไอเทมออกจากฉาก
		queue_free()
