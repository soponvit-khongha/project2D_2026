extends Node2D

# อ้างอิงโหนด TextBox ที่วางอยู่ในฉากนี้
@export var text_box: CanvasLayer

func _ready() -> void:
	# สั่งส่งข้อความเข้าคิวทันทีที่เริ่มฉาก
	text_box.queue_text("กด Spacebar หรือ Enter หรือ คลิก เพื่ออ่านข้อความถัดไป")
	text_box.queue_text("กลัวๆ","hero")
