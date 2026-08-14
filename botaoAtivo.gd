class_name BotaoAtivo
extends Area2D

signal desafio_completo

#Variaveis de entrada para Sprite
@export var textura_normal: Texture2D
@export var textura_pressionado: Texture2D
#Variavel para entrada de temporizador
@export var tempo_para_resetar: float = 5.0
#Variavel botao secundario(passivo)
@export var botao2: Area2D

#Variaveis Gerais
var player_perto = false
var botao_pressionado = false
var botao_confirmado = false

func _ready():
	$Sprite2D.texture = textura_normal

func _process(delta):
	if player_perto and Input.is_action_just_pressed("interagir") and not botao_pressionado and not botao_confirmado:
		#pressionado
		botao_pressionado = true
		$Sprite2D.texture = textura_pressionado
		#temporizado
		await get_tree().create_timer(tempo_para_resetar).timeout
		#confirmado
		if not botao_confirmado:
			botao_pressionado = false
			$Sprite2D.texture = textura_normal

#Entrada
func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		player_perto = true

#Saida
func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		player_perto = false

#Chamada do botao passivo quando pressionado
func confirmar():
	if botao_pressionado and not botao_confirmado:
		botao_confirmado = true
		desafio_completo.emit()
