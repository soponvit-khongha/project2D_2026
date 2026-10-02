extends Node

# 1. คลังจำห้องที่เคยอ่านบทพูดเปิดฉากไปแล้ว
var talked_rooms: Dictionary = {}

# 2. คลังเก็บไอเทมในเกม (Key = item_id, Value = true)
var items: Dictionary = {}

# --- ฟังก์ชันจัดการบทพูดห้อง ---
func mark_room_as_talked(room_name: String) -> void:
	talked_rooms[room_name] = true

func is_room_talked(room_name: String) -> bool:
	return talked_rooms.get(room_name, false)

# --- ฟังก์ชันจัดการไอเทม (ใช้ร่วมกันทั้งกุญแจและไอเทมอื่นๆ) ---
func collect_item(item_id: String) -> void:
	if item_id != "":
		items[item_id] = true
		print("เก็บไอเทมสำเร็จ: ", item_id) # ไว้เช็กใน Output ว่าเก็บเข้าจริงไหม

func has_item(item_id: String) -> bool:
	return items.get(item_id, false)

# --- ฟังก์ชันล้างข้อมูลทั้งหมดเพื่อเริ่มเกมใหม่ ---
func reset_game() -> void:
	talked_rooms.clear()
	items.clear()
