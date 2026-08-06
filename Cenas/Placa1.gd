extends Node2D

var player_perto = false
var dialogo_aberto = false
var texto_visivel = false


#FUNCAO QUE CARREGA LOGO NO INICIO DO JOGO
func _ready():
	$Label.visible = false
	$TextureRect.visible = false

#FUNCAO EXECUTADA A CADA FRAME DO JOGO 
func _process(delta):
	if player_perto and Input.is_action_just_pressed("interagir"): #(se for botao de interagir mexer aqui ! )
		dialogo_aberto = !dialogo_aberto
		$TextureRect.visible = dialogo_aberto


#FUNCAO QUANDO O CORPO ENTRA NA AREA2D
func _on_area_2d_body_entered(body):
	if body.name == "CharacterBody2D":
		player_perto = true
		$Label.visible = true
		
#FUNCAO QUANDO O CORPO SAI DA AREA2D 
func _on_area_2d_body_exited(body):
	if body.name == "CharacterBody2D":
		player_perto = false
		$Label.visible = false
		$TextureRect.visible = false
		dialogo_aberto = false
