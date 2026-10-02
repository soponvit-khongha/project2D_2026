extends CanvasLayer

enum State { READY, READING, FINISHED }
var current_state = State.READY

@export var character_node: Node2D
@onready var container = $MarginContainer
@onready var label: RichTextLabel = $MarginContainer/MarginContainer2/HBoxContainer/Text
@onready var end_symbol = $MarginContainer/MarginContainer2/HBoxContainer/end
@onready var start_symbol = $MarginContainer/MarginContainer2/HBoxContainer/start

# --- Node เสียงพิมพ์ข้อความ ---
@onready var voice_sound: AudioStreamPlayer = $VoiceSound

var text_queue = []
@export var read_rate: float = 0.12

var current_tween: Tween

# --- สำหรับอนิเมชันตัว V จิ้มลงเบาๆ ---
var v_tween: Tween
@export var v_dip_distance: float = 4.0 # ระยะจิ้มลงล่าง (พิกเซล)
@export var v_dip_speed: float = 0.35   # ความเร็วในการจิ้ม (วินาที)

var last_char_index: int = 0 # เช็กตัวอักษรล่าสุดเพื่อไม่ให้เล่นเสียงซ้ำ

func _ready() -> void:
	label.bbcode_enabled = true
	hide_textbox()
	start_symbol.hide()

func _process(_delta: float) -> void:
	match current_state:
		State.READY:
			if not text_queue.is_empty():
				display_text()

func _unhandled_input(event: InputEvent) -> void:
	if not container.visible:
		return
		
	var is_advance_action = event.is_action_pressed("ui_accept") or (
		event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	)
	
	if is_advance_action:
		match current_state:
			State.READING:
				if current_tween and current_tween.is_running():
					current_tween.kill()
				
				if voice_sound:
					voice_sound.stop()
					
				label.visible_characters = -1
				show_finished_symbol()
				change_state(State.FINISHED)
				get_viewport().set_input_as_handled()
				
			State.FINISHED:
				change_state(State.READY)
				hide_textbox()
				get_viewport().set_input_as_handled()

func hide_textbox() -> void:
	if v_tween:
		v_tween.kill()
	end_symbol.text = ""
	end_symbol.hide()
	label.text = ""
	container.hide()
	
	if voice_sound:
		voice_sound.stop()
	
	if character_node != null:
		character_node.hide()

func show_textbox() -> void:
	container.show()
	end_symbol.hide()

func queue_text(next_text: String, speaker_name: String = "", anim_name: String = "ยืนเฉยๆ") -> void:
	var dialogue_data = {
		"text": next_text,
		"speaker": speaker_name,
		"anim": anim_name
	}
	text_queue.push_back(dialogue_data)

func display_text() -> void:
	var current_data = text_queue.pop_front()
	
	var raw_text = current_data["text"]
	var speaker = current_data["speaker"]
	var anim_name = current_data["anim"]
	
	if character_node != null:
		if speaker != "":
			character_node.show()
			
			if character_node.has_node("AnimationPlayer"):
				var anim_player = character_node.get_node("AnimationPlayer") as AnimationPlayer
				if anim_player.has_animation(anim_name):
					var anim_resource = anim_player.get_animation(anim_name)
					
					if anim_name == "ยืนเฉยๆ":
						anim_resource.loop_mode = Animation.LOOP_LINEAR
					else:
						anim_resource.loop_mode = Animation.LOOP_NONE
					
					anim_player.play(anim_name)
		else:
			character_node.hide()
	
	var formatted_text = "\t" + raw_text
	
	label.text = "[wave amp=7.0 freq=3.0]" + formatted_text + "[/wave]"
	label.visible_characters = 0
	last_char_index = 0
	show_textbox()
	change_state(State.READING)
	
	current_tween = create_tween()
	var total_chars = formatted_text.length()
	var duration = total_chars * read_rate
	
	current_tween.tween_method(_update_visible_characters, 0, total_chars, duration)
	current_tween.finished.connect(_on_tween_finished)

# ฟังก์ชันอัปเดตตัวอักษรพร้อมเล่นเสียง
func _update_visible_characters(value: float) -> void:
	var current_char_count = int(value)
	
	if current_char_count > last_char_index:
		label.visible_characters = current_char_count
		last_char_index = current_char_count
		
		# เช็กข้ามช่องว่าง Spacebar / Tab
		var parsed_text = label.get_parsed_text()
		if last_char_index <= parsed_text.length():
			var current_char = parsed_text[last_char_index - 1]
			if current_char == " " or current_char == "\t":
				return
		
		# เล่นเสียง
		if voice_sound and voice_sound.stream:
			voice_sound.pitch_scale = randf_range(0.85, 1.1)
			voice_sound.play() # ไม่ต้องใส่ 0.0 ให้ Max Polyphony จัดการเอง

func _on_tween_finished() -> void:
	if voice_sound:
		voice_sound.stop()
		
	if current_state == State.READING:
		label.visible_characters = -1
		show_finished_symbol()
		change_state(State.FINISHED)

func show_finished_symbol() -> void:
	end_symbol.text = "v"
	end_symbol.show()
	
	if v_tween:
		v_tween.kill()
		
	await get_tree().process_frame
	
	v_tween = create_tween().set_loops()
	var base_y = end_symbol.position.y
	
	v_tween.tween_property(end_symbol, "position:y", base_y + v_dip_distance, v_dip_speed)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	v_tween.tween_property(end_symbol, "position:y", base_y, v_dip_speed)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func change_state(next_state: State) -> void:
	current_state = next_state
