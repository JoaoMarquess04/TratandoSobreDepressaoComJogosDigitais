extends Node2D

#================================================
#VARIAVEIS DA VBOXCONTAINER/E BOTÃO DE CONFIG
#================================================
@onready var botoes_principais: VBoxContainer = $"Hud/Botões principais"
@onready var configuracao: Panel = $Hud/Configuração

#================================================
#BOTÃO DE INICIAR
#================================================
#Função do botão iniciar
func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Tutorials.tscn")

#================================================
#BOTÃO DE CONFIGURAÇÕES
#================================================
#Função ativada ao iniciar o jogo, esconde o menu de opções 
func _ready() -> void:
	botoes_principais.visible = true
	configuracao.visible = false

#Função ativada ao entrar no menu de configurações, esconde o menu principal 
func _on_configurações_do_jogo_pressed() -> void:
	botoes_principais.visible = false
	configuracao.visible = true
	
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
