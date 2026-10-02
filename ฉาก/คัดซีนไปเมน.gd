extends Node2D

@export_file("*.tscn") var next_scene_path: String = "res://ฉาก/คำอธิบาย.tscn"

# ดึงโหนดดวงตาและโหนดเล่นเสียงมาควบคุม
@onready var eye_node: Node2D = $ตากระพริบ2
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	# สั่งเล่นเสียงหลังจากผ่านไป 1 วินาที (ทำงานแยกเป็นฉากหลัง)
	play_audio_delayed(1.0)
	
	# 1. ปิดตาไว้ก่อนโดยทำให้โปร่งใส
	eye_node.modulate.a = 0.0
	eye_node.show()
	
	# รอ 3 วินาที
	await get_tree().create_timer(3.0).timeout
	
	# 2. ปรากฏดวงตาขึ้นมาเต็มตัว
	eye_node.modulate.a = 1.0
	
	# ค้นหา AnimationPlayer ที่ซ่อนอยู่ในโหนด ตากระพริบ2
	var anim_player: AnimationPlayer = eye_node.find_child("AnimationPlayer", true, false)
	
	if anim_player:
		anim_player.stop() # รีเซ็ตหัวอ่าน
		var anim_list = anim_player.get_animation_list()
		
		if anim_list.size() > 0:
			# เล่นแอนิเมชันตัวแรก หรือชื่อ "ขยับตา"
			var anim_name = "ขยับตา" if anim_player.has_animation("ขยับตา") else anim_list[0]
			anim_player.play(anim_name)
			
			# รอจนกว่าแอนิเมชันขยับตาจะเล่นจบ!
			await anim_player.animation_finished
	
	# 3. ค้างภาพตาไว้ 1 วินาที
	await get_tree().create_timer(1.0).timeout
	
	# 4. สั่นดวงตา 4 วินาที
	await shake_eye(4.0)
	
	# 5. สลายตัว (Fade Out)
	await fade_out_eye(0.8)
	
	# 6. ค้างฉากดำไว้ 2 วินาที
	await get_tree().create_timer(2.0).timeout
	
	# 7. เปลี่ยนไปยังฉากคำอธิบาย
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)

# ฟังก์ชันเล่นเสียงตามเวลาหน่วงที่กำหนด
func play_audio_delayed(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(audio_player):
		audio_player.play()

# ฟังก์ชันสั่งสั่น
func shake_eye(duration: float) -> void:
	var original_pos = eye_node.position
	var shake_tween = create_tween()
	var step_time = 0.05
	var total_steps = int(duration / step_time)
	
	for i in range(total_steps):
		var offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		shake_tween.tween_property(eye_node, "position", original_pos + offset, step_time)
	
	shake_tween.tween_property(eye_node, "position", original_pos, 0.0)
	await shake_tween.finished

# ฟังก์ชันสั่งสลาย
func fade_out_eye(duration: float) -> void:
	var fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(eye_node, "modulate:a", 0.0, duration)
	fade_tween.tween_property(eye_node, "scale", eye_node.scale * 1.2, duration)
	await fade_tween.finished
	eye_node.hide()
