extends MarginContainer

signal dialog_finished()
var texts_to_display: Array[String] = []
var current_index := 0
var typing_speed := 0.03
var is_typing := false
var waiting_input := false
var started := false

@onready var text_label = $NinePatchRect/Text_Label
@onready var indicator = $Indicator

var sprite_tecla_f = preload("res://sprites/BotCaixaDialogo.png")
var sprite_tecla_f_pressed = preload("res://sprites/BotCaixaDialogoPressed.png")
var sprite_botao_b = preload("res://sprites/BotCaixaDialogoB.png")
var sprite_botao_b_pressed = preload("res://sprites/BotCaixaDialogoBPressed.png")
var usando_controle := false
var _pausou_jogo := false

#FUNCAO PRA CARREGAR NO INICIO DO JOGO
func _ready():
	if not get_tree().paused:
		get_tree().paused = true
		_pausou_jogo = true
	pivot_offset = size / 2
	var target_scale = scale
	scale = Vector2.ZERO
	indicator.visible = false
	var tween = create_tween()
	tween.tween_property(
		self,
		"scale",
		target_scale,
		0.25
	).set_trans(Tween.TRANS_BACK)

#FUNCAO DE INICIAR DIALOGO
func start_dialog(texts: Array[String]):
	if started:
		return
	started = true
	texts_to_display = texts
	current_index = 0
	show_text()

#FUNCAO DE MOSTRAR O TEXTO
func show_text():
	if current_index >= texts_to_display.size():
		close_dialog()
		return
	is_typing = true
	waiting_input = false
	text_label.text = ""
	indicator.visible = false
	_type_text(texts_to_display[current_index])

#FUNCAO DE DIGITAR O TEXTO
func _type_text(text: String):
	text_label.text = ""
	for i in range(text.length()):
		if !is_typing:
			return
		text_label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout
	is_typing = false
	waiting_input = true
	indicator.visible = true

#FUNCAO CHAMADA PELO JOGADOR QUANDO ELE APERTA UMA TECLA
func _unhandled_input(event):
	# troca o indicador F/B conforme o ultimo dispositivo usado
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if not usando_controle:
			usando_controle = true
			indicator.texture.set_frame_texture(0, sprite_botao_b)
			indicator.texture.set_frame_texture(1, sprite_botao_b_pressed)
	elif event is InputEventKey or event is InputEventMouseButton:
		if usando_controle:
			usando_controle = false
			indicator.texture.set_frame_texture(0, sprite_tecla_f)
			indicator.texture.set_frame_texture(1, sprite_tecla_f_pressed)

	if !event.is_action_pressed("interagir"):
		return
	get_viewport().set_input_as_handled()
	# COMPLETA O TEXTO INSTANTANEAMENTE
	if is_typing:
		is_typing = false
		text_label.text = texts_to_display[current_index]
		waiting_input = true
		indicator.visible = true
		return

	# VAI PARA A PROXIMA PARTE
	if waiting_input:
		waiting_input = false
		current_index += 1
		show_text()

#FUNCAO DE FECHAR DIALOGO
func close_dialog():
	var tween = create_tween()
	tween.tween_property(
		self,
		"scale",
		Vector2.ZERO,
		0.25
	).set_trans(Tween.TRANS_BACK)
	await tween.finished
	dialog_finished.emit()
	if _pausou_jogo:
		get_tree().paused = false
		_pausou_jogo = false
	queue_free()

func _exit_tree():
	if _pausou_jogo:
		get_tree().paused = false
		_pausou_jogo = false
