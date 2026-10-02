extends Area2D

# กำหนด ID ไอเทม ("medicine" สำหรับยา หรือ "energy_drink" สำหรับเครื่องดื่ม)
@export var item_id: String = "medicine"

@export_category("ตั้งค่าฉากถัดไป")
@export_file("*.tscn") var next_scene_path: String = ""

@export_category("รูปเมาส์")
@export var custom_cursor_texture: Texture2D

# 👻 อ้างอิงโหนดรูปผีและโหนดเสียง
@onready var ghost_sprite: CanvasItem = get_node_or_null("CanvasLayer/GhostSprite")
@onready var audio_stream_player: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer")

var is_hovered: bool = false
var is_collecting: bool = false

var hover_cursor: Texture2D:
	get:
		return custom_cursor_texture

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if GameManager.has_item("medicine") or GameManager.has_item("energy_drink"):
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
		
		# 1. บันทึกไอเทมลง GameManager
		GameManager.collect_item(item_id)
		
		# 2. คืนค่าเมาส์เป็นปกติ
		Input.set_custom_mouse_cursor(null)
		
		# 3. เล่นเสียง Jumpscare
		if audio_stream_player and audio_stream_player.stream:
			audio_stream_player.play(0.0)
			
		# 4. 👻 แสดงภาพผี + สั่งสั่นภาพ (Shake)
		if ghost_sprite:
			ghost_sprite.visible = true
			play_ghost_shake() # เรียกฟังก์ชันสั่นภาพผี
		
		# 5. รอ 0.5 วินาที
		await get_tree().create_timer(2.0).timeout
		
		# 6. เปลี่ยนฉาก
		if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
			get_tree().change_scene_to_file(next_scene_path)
		else:
			queue_free()

# 🫨 ฟังก์ชันทำให้ภาพผีสั่นเขย่าส

# 🫨 ฟังก์ชันทำให้ภาพผีสั่นเขย่าสุ่มตำแหน่ง
func play_ghost_shake() -> void:
	if not ghost_sprite:
		return
	var original_pos: Vector2 = ghost_sprite.position
	var tween: Tween = create_tween()
	
	# เขย่าตำแหน่งไปมาสุ่มๆ 6 รอบอย่างเร็ว
	for i in range(6):
		var random_offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
		tween.tween_property(ghost_sprite, "position", original_pos + random_offset, 0.05)
	
	# เคลียร์ตำแหน่งกลับมาที่เดิม
	tween.tween_property(ghost_sprite, "position", original_pos, 0.05)
