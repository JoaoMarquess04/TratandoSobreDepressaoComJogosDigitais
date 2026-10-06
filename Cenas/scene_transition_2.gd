extends Area2D

const DESTINO := "res://Cenas/NiveisFarol/Nivel-1/NivelVoAbby.tscn"
const DURACAO_FADE := 1.25
var trocando_cena := false
var tela_preta: ColorRect

func _ready() -> void:
	var camada := CanvasLayer.new()
	camada.layer = 100
	camada.name = "FadeLayer"
	add_child(camada)
	tela_preta = ColorRect.new()
	tela_preta.name = "Fade"
	tela_preta.color = Color(0, 0, 0, 1)
	tela_preta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela_preta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	camada.add_child(tela_preta)
	var entrada := create_tween()
	entrada.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	entrada.tween_property(tela_preta, "color:a", 0.0, DURACAO_FADE)

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D or trocando_cena:
		return
	trocando_cena = true
	var saida := create_tween()
	saida.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	saida.tween_property(tela_preta, "color:a", 1.0, DURACAO_FADE)
	await saida.finished
	get_tree().change_scene_to_file.call_deferred(DESTINO)
