extends Area2D

@export var hover_cursor: Texture2D
@export var click_cursor: Texture2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var is_hovered: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	is_hovered = true
	Input.set_custom_mouse_cursor(hover_cursor)

func _on_mouse_exited() -> void:
	is_hovered = false
	Input.set_custom_mouse_cursor(null)

# เปลี่ยนเป็น _input เพื่อให้ทำงานก่อนที่ UI (ColorRect/TextureButton) จะดักจับเมาส์ไป
func _input(event: InputEvent) -> void:
	if is_hovered and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Input.set_custom_mouse_cursor(click_cursor)
			if audio_stream_player and audio_stream_player.stream:
				audio_stream_player.play(0.0)
		else:
			if is_hovered:
				Input.set_custom_mouse_cursor(hover_cursor)
			else:
				Input.set_custom_mouse_cursor(null)
