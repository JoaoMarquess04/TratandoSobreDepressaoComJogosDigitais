extends Area2D

@export var textura_normal: Texture2D
@export var textura_pressionado: Texture2D

var player_perto = false
var botao_pressionado = false

func _ready():
	$Sprite2D.texture = textura_normal

func _process(delta):
	if player_perto and Input.is_action_just_pressed("interagir"):
		botao_pressionado = !botao_pressionado
		$Sprite2D.texture = textura_pressionado if botao_pressionado else textura_normal

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		player_perto = true

func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		player_perto = false
