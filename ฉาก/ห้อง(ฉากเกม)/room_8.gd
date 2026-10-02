extends Node2D

@onready var ghost_sprite: Sprite2D = $CanvasLayer/GhostSprite
@onready var audio_player: AudioStreamPlayer = $CanvasLayer/AudioStreamPlayer

var can_input: bool = true 
var jumpscare_triggered: bool = false

func _ready() -> void:
	ghost_sprite.visible = false
	
	# เช็กว่าห้องนี้เคยทำ Jumpscare ไปหรือยัง (ป้องกันเล่นซ้ำตอนเดินกลับมา)
	if not GameManager.is_room_talked(name + "_jumpscare_done"):
		var text_box = get_text_box()
		if text_box:
			# 1. ส่งข้อความช่วงแรกเข้าคิวทั้งหมด
			text_box.queue_text("I feel the pressure has lifted... but it's weird, I could've sworn there was something here.","hero","ยืนเฉยๆ")
			text_box.queue_text("Maybe I'm just too exhausted.")
			text_box.queue_text(". . . .")
			text_box.queue_text("But I know for sure there was something here!")
			
			# 2. รอจนกว่าข้อความชุดแรกทั้งหมดจะถูกผู้เล่นคลิกอ่านจนจบและคิวว่างลง
			while not text_box.text_queue.is_empty() or text_box.current_state != text_box.State.READY:
				await get_tree().process_frame
			
			await get_tree().process_frame
			
			# --- 3. เริ่มกระบวนการ Jumpscare (ล็อกการกดทั้งหมดทันที) ---
			can_input = false 
			jumpscare_triggered = true
			
			# ผีโผล่ + เล่นเสียง
			ghost_sprite.visible = true
			if audio_player:
				audio_player.play()
				
			# โชว์ผีค้างไว้ 2 วินาที
			await get_tree().create_timer(2.0).timeout 
			ghost_sprite.visible = false
			
			# --- 4. ปลดล็อกการกดก่อน เพื่อให้ผู้เล่นคลิกอ่านประโยคตกใจต่อได้ ---
			can_input = true 
			
			# แสดงประโยคตกใจต่อ
			text_box.queue_text("WHAT THE HELL WAS THAT?!","hero","ตกใจ")
			
			# 5. รอให้ประโยคตกใจเล่นจบ แล้วค่อยบันทึกสถานะว่าห้องนี้จบเหตุการณ์แล้ว
			while not text_box.text_queue.is_empty() or text_box.current_state != text_box.State.READY:
				await get_tree().process_frame
				
			GameManager.mark_room_as_talked(name + "_jumpscare_done")

# 🖱️ ฟังก์ชันบล็อกการคลิกทั้งหมดเฉพาะช่วงที่สั่งล็อก
func _input(event: InputEvent) -> void:
	if not can_input:
		var is_click = (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed())
		var is_accept = event.is_action_pressed("ui_accept")
		
		if is_click or is_accept:
			get_viewport().set_input_as_handled()

func get_text_box() -> Node:
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.find_child("TextBox", true, false)
	return null
