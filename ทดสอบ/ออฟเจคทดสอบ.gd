extends Area2D

# สามารถแก้ไขข้อความที่จะให้อ่านได้จาก Inspector โดยไม่ต้องแก้โค้ด!
@export var dialogue_lines: Array[String] = [
	"นี่คือประตูที่ล็อกอยู่...",
	"ดูเหมือนจะต้องหาลูกกุญแจมาเปิด"
]

# ตรวจจับการคลิกวัตถุให้อัตโนมัติ (ไม่มีคำว่า on_)
func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		trigger_dialogue()

func trigger_dialogue() -> void:
	for line in dialogue_lines:
		TextBox.queue_text(line)
