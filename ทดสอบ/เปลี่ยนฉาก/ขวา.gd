extends Area2D

enum Direction { UP, DOWN, LEFT, RIGHT, CUSTOM }
@export var preset_direction: Direction = Direction.CUSTOM # ปรับ default เป็น CUSTOM เพื่อไม่ให้พัง

@export_category("ตั้งค่าฉากปลายทาง")
@export_file("*.tscn") var target_scene: String = ""
@export var node_to_show: Node2D
@export var node_to_hide: Node2D

@export_category("รูปเมาส์")
@export var custom_cursor_texture: Texture2D

@onready var audio_stream_player: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer")

var is_hovered: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# ดึงรูปเมาส์ที่ถูกต้องมาใช้งาน
func get_active_cursor() -> Texture2D:
	if preset_direction == Direction.CUSTOM or custom_cursor_texture != null:
		return custom_cursor_texture
	
	var path = ""
	match preset_direction:
		Direction.UP: path = "res://รูปเมาส์/up.png"
		Direction.DOWN: path = "res://รูปเมาส์/down.png"
		Direction.LEFT: path = "res://รูปเมาส์/left.png"
		Direction.RIGHT: path = "res://รูปเมาส์/right.png"
		
	if path != "" and ResourceLoader.exists(path):
		return load(path)
		
	return custom_cursor_texture

func is_textbox_active() -> bool:
	var current_scene = get_tree().current_scene
	if current_scene:
		var text_box = current_scene.find_child("TextBox", true, false)
		if text_box:
			# เช็ก container ข้างในว่ามันเปิดแสดงผลอยู่ไหม
			var container = text_box.get_node_or_null("MarginContainer")
			if container and container.visible:
				return true
				
	return false

func _process(_delta: float) -> void:
	if is_hovered and is_textbox_active():
		Input.set_custom_mouse_cursor(null)

func _on_mouse_entered() -> void:
	if is_textbox_active():
		return
	is_hovered = true
	var cursor = get_active_cursor()
	if cursor:
		Input.set_custom_mouse_cursor(cursor)

func _on_mouse_exited() -> void:
	is_hovered = false
	
	# ยิง Raycast/Point เช็กว่าตำแหน่งเมาส์ตอนนี้ยังลอยอยู่บน Area2D หรือเปล่า
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	
	var results = space_state.intersect_point(query)
	
	# วนลูปดูว่าจุดที่เมาส์อยู่ มี Area2D ซ่อนอยู่ใต้ปุ่มไหม
	var found_area: Area2D = null
	for result in results:
		if result.collider is Area2D and result.collider != self:
			found_area = result.collider
			break
			
	if found_area and "hover_cursor" in found_area and found_area.hover_cursor:
		# ถ้าถอยเมาส์ออกจาก "ลง" แล้วเจอ Area2D ข้างใต้ -> ให้ดึงเมาส์ของ Area2D มาใช้ทันที!
		Input.set_custom_mouse_cursor(found_area.hover_cursor)
	else:
		# ถ้าถอยออกไปเจอพื้นที่ว่างเปล่า -> คืนเป็นเมาส์ปกติของโปรเจกต์
		Input.set_custom_mouse_cursor(null)

func _unhandled_input(event: InputEvent) -> void:
	if is_textbox_active() or not is_hovered:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if audio_stream_player and audio_stream_player.stream:
			audio_stream_player.play(0.0)
			
		Input.set_custom_mouse_cursor(null)
		
		# 1. เปลี่ยนมุมมองในห้องเดิม
		if node_to_show:
			node_to_show.visible = true
			if node_to_hide:
				node_to_hide.visible = false
				
		# 2. วาร์ปไปฉากใหม่
		elif target_scene != "" and ResourceLoader.exists(target_scene):
			get_tree().change_scene_to_file(target_scene)
		elif target_scene != "":
			print("ไม่พบไฟล์ฉาก: ", target_scene)
