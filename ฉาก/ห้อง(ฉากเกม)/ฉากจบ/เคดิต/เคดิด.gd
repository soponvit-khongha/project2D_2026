extends Node2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 1. ล้างข้อมูลห้องที่เคยคุยและไอเทมใน GameManager ทั้งหมด
		GameManager.reset_game()
		
		# 2. โหลดฉากหลักใหม่
		get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
