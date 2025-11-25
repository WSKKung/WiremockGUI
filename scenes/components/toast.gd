class_name Toast
extends Window

@export var text: String = "Sample Text"
@export var duration: float = 2
@export var duration_fade_in: float = 0.5
@export var duration_fade_out: float = 0.5
@export var padding_horizontal: int = 20
@export var padding_vertical: int = 20
@export var margin_horizontal: int = 40
@export var margin_vertical: int = 40

@onready var control: Control = %Control
@onready var label: Label = %Label

var tween: Tween

func _ready():
	set_text(text)
	start()
	

func set_text(s: String) -> void:
	label.text = s
	# calculate text bounding box size
	var font = label.get_theme_default_font()
	if label.label_settings != null:
		font = label.label_settings.font
	var string_size = font.get_multiline_string_size(s, label.horizontal_alignment)
	size = string_size
	size.x += padding_horizontal * 2
	size.y += padding_vertical * 2
	# calculate toast window position to anchor window in bottom left position of the viewport
	var main_window_size = get_tree().root.get_viewport().get_visible_rect().size
	position.x = main_window_size.x - size.x - margin_horizontal
	position.y = main_window_size.y - size.y - margin_vertical

func start() -> void:
	if tween != null:
		return
	
	visible = true
	
	tween = create_tween()
	if duration_fade_in > 0:
		control.modulate = Color.TRANSPARENT
		tween.tween_property(control, "modulate", Color.WHITE, duration_fade_in)
		
	tween.tween_interval(duration)
	
	if duration_fade_out > 0:
		tween.tween_property(control, "modulate", Color.TRANSPARENT, duration_fade_out)
	
	tween.finished.connect(stop)

func stop() -> void:
	if tween != null:
		tween.stop()
		tween = null
	visible = false
	queue_free()

func _on_close_requested():
	stop()
