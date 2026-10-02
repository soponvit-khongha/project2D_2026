extends Area2D

# 1. ประกาศ Signal ไว้ด้านบนสุดของไฟล์
signal paper_closed(read_count: int)

@export_category("ตั้งค่าเมาส์")
@export var custom_cursor_texture: Texture2D

@onready var note_p = get_node_or_null("CanvasLayer/P")
@onready var small_paper = get_node_or_null("NotePadStoryRemovebgPre")
@onready var sfx_player: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer")

var is_hovered: bool = false
var is_note_open: bool = false
var read_count: int = 0 # 2. ตัวแปรนับจำนวนครั้ง

var hover_cursor: Texture2D:
	get:
		return custom_cursor_texture

func _ready() -> void:
	if note_p:
		note_p.visible = false
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

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
	if is_textbox_active() or is_note_open:
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
	if is_textbox_active():
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 1. คลิกเปิดกระดาษใหญ่
		if not is_note_open and is_hovered:
			open_note()
			
		# 2. คลิกปิดกระดาษใหญ่
		elif is_note_open:
			close_note()

func open_note() -> void:
	is_note_open = true
	Input.set_custom_mouse_cursor(null)
	
	if note_p:
		note_p.visible = true
	if small_paper:
		small_paper.visible = false
		
	if sfx_player:
		sfx_player.play()

func close_note() -> void:
	is_note_open = false
	read_count += 1
	
	if note_p:
		note_p.visible = false
	if small_paper:
		small_paper.visible = true
		
	if sfx_player:
		sfx_player.play()
	
	if is_hovered and custom_cursor_texture:
		Input.set_custom_mouse_cursor(custom_cursor_texture)
		
	# 3. ส่งสัญญาณแจ้งว่าปิดกระดาษแล้ว
	paper_closed.emit(read_count)
