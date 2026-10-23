extends Node2D

#================================================
#VARIAVEIS DA VBOXCONTAINER/E BOTÃO DE CONFIG
#================================================
@onready var botoes_principais: VBoxContainer = $"Hud/Botões principais"
@onready var configuracao: Panel = $Hud/Configuração
var cutscene_player: VideoStreamPlayer
var cutscene_camada: CanvasLayer
var iniciando := false

#================================================
#BOTÃO DE INICIAR
#================================================
#Função do botão iniciar
func _on_jogar_pressed() -> void:
	if iniciando:
		return
	iniciando = true
	botoes_principais.visible = false
	$Hud.get_node("Bimini,AviSnowNoWay(withAviSnow)[ncsRelease]").stop()
	cutscene_player = VideoStreamPlayer.new()
	cutscene_player.name = "CutsceneInicial"
	cutscene_player.stream = load("res://VideoScenes/CutsceneInicial2.ogv")
	cutscene_player.expand = true
	cutscene_player.autoplay = true
	cutscene_player.finished.connect(_cutscene_terminou)
	var camada := CanvasLayer.new()
	camada.layer = 100
	add_child(camada)
	cutscene_camada = camada
	camada.add_child(cutscene_player)
	cutscene_player.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# botao de pular: focado de cara, entao no controle eh so apertar A
	var botao_pular := Button.new()
	botao_pular.name = "PularCutscene"
	botao_pular.text = "PULAR"
	botao_pular.add_theme_font_size_override("font_size", 20)
	camada.add_child(botao_pular)
	botao_pular.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 20)
	botao_pular.pressed.connect(_pular_cutscene)
	botao_pular.grab_focus()

	cutscene_player.play()

func _cutscene_terminou() -> void:
	get_tree().change_scene_to_file("res://Cenas/CenaFarol-1.tscn")

# para o video, desconecta o finished e troca de cena sem disparar o fluxo normal
func _pular_cutscene() -> void:
	if cutscene_player == null:
		return
	cutscene_player.stop()
	cutscene_player.finished.disconnect(_cutscene_terminou)
	cutscene_camada.queue_free()
	cutscene_player = null
	get_tree().change_scene_to_file("res://Cenas/CenaFarol-1.tscn")

# B / start tambem pulam a cutscene (joypad entra por _unhandled_input)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and cutscene_player != null:
		_pular_cutscene()

# teclado nao chega em _unhandled_input: Esc vem por aqui
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and cutscene_player != null:
		_pular_cutscene()

#================================================
#BOTÃO DE CONFIGURAÇÕES
#================================================
#Função ativada ao iniciar o jogo, esconde o menu de opções 
func _ready() -> void:
	botoes_principais.visible = true
	configuracao.visible = false
	botoes_principais.get_node("Jogar").grab_focus()

#Função ativada ao entrar no menu de configurações, esconde o menu principal 
func _on_configurações_do_jogo_pressed() -> void:
	botoes_principais.visible = false
	configuracao.visible = true
	configuracao.get_node("ControleDeAudio").grab_focus()
	
#Função para retornar ao menu principal, utiliza da função inicial ao abrir o jogo 
func _on_voltar_ao_menu_opcoes_pressed() -> void:
	_ready()

#================================================
#BOTÃO DE SAIR DO JOGO 
#================================================
#Função para sair do jogo ao clicar no botão sair
func _on_sair_pressed() -> void:
	get_tree().quit()

#================================================
#FUNÇÃO DO BOTÃO DE CRÉDITOS
#================================================
#Função para redirecionar a cena de créditos ao clicar no botão créditos
func _on_créditos_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/créditos.tscn")

#================================================
#BOTÃO DO ATALHO PRO NÍVEL DA VÓ
#================================================
#Função para ir direto ao nível da avó, sem passar pela cutscene
func _on_nivel_vo_abby_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/NiveisFarol/Nivel-1/NivelVoAbby.tscn")
