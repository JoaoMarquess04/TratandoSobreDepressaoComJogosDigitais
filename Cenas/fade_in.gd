extends CanvasLayer

@export var duracao: float = 1.25

func _ready() -> void:
    layer = 100
    var tela := ColorRect.new()
    tela.color = Color(0, 0, 0, 1)
    tela.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tela.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(tela)
    var fade := create_tween()
    fade.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    fade.tween_property(tela, "color:a", 0.0, duracao)
    fade.tween_callback(tela.queue_free)
