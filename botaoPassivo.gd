extends Area2D

#variaveis dos sprites
@export var textura_normal: Texture2D
@export var textura_pressionado: Texture2D
#variavel de entrada do botao ativo
@export var botao1: BotaoAtivo

#variaveis gerais
var player_perto = false
var pressionado = false

func _ready():
	$Sprite2D.texture = textura_normal

func _process(delta):
	if player_perto and Input.is_action_just_pressed("interagir") and not pressionado:
		if botao1.botao_pressionado and not botao1.botao_confirmado:
			pressionado = true
			$Sprite2D.texture = textura_pressionado
			botao1.confirmar()

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		player_perto = true

func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		player_perto = false
