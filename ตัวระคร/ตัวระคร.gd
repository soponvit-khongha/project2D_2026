extends Node2D

@onready var anim = $AnimationPlayer

func play_anim(anim_name: String) -> void:
	if anim.has_animation(anim_name):
		# บังคับถ้าเป็นท่า "ตกใจ" ให้ปิด Loop แบบเด็ดขาด
		if anim_name == "ตกใจ":
			anim.get_animation(anim_name).loop_mode = Animation.LOOP_NONE
		
		anim.play(anim_name)

func play_idle() -> void:
	play_anim("ยืนเฉยๆ")
