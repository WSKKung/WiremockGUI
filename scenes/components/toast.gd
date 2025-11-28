class_name Toast
extends Control

@export var text: String = "Sample Text"
@export var duration: float = 2
@export var duration_fade_in: float = 0.5
@export var duration_fade_out: float = 0.5
@export var margin_horizontal: int = 40
@export var margin_vertical: int = 40

@onready var label: Label = %Label

var tween: Tween

func _ready():
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
	set_text(text)
	start()

func set_text(s: String) -> void:
	label.text = s

func align_position() -> void:
	var main_window_size = get_tree().root.get_visible_rect().size
	position.x = main_window_size.x - size.x - margin_horizontal
	position.y = main_window_size.y - size.y - margin_vertical

func start() -> void:
	if tween != null:
		return
	
	tween = create_tween()
	tween.tween_callback(align_position)
	if duration_fade_in > 0:
		tween.tween_property(self, "modulate", Color(Color.BLACK, 0.0), 0.0)
		tween.tween_property(self, "modulate", Color.WHITE, duration_fade_in)
		
	tween.tween_interval(duration)
	
	if duration_fade_out > 0:
		tween.tween_property(self, "modulate", Color(Color.BLACK, 0.0), duration_fade_out)
	
	tween.finished.connect(stop)

func stop() -> void:
	if tween != null:
		tween.stop()
		tween = null
	queue_free()

func _on_close_requested():
	stop()

func _on_viewport_size_changed():
	align_position()
