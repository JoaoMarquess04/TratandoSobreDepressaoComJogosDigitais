extends Node2D

var player_perto = false
var dialogo_aberto = false
var texto_visivel = false

func _ready():
	$Label.visible = false
	
	$TextureRect.visible = false
	
func _process(delta):

	if player_perto and Input.is_action_just_pressed("interagir"): #(se for botao de interagir mexer aqui ! )
		#texto_visivel = !texto_visivel
		#$Label2.visible = texto_visivel
		
		dialogo_aberto = !dialogo_aberto
		$TextureRect.visible = dialogo_aberto

		interagir()

func interagir():
	print("Você interagiu com a placa!")

func _on_area_2d_body_entered(body):

	if body.name == "CharacterBody2D":
		player_perto = true
		$Label.visible = true
		

func _on_area_2d_body_exited(body):

	if body.name == "CharacterBody2D":
		player_perto = false
		$Label.visible = false
		
		$TextureRect.visible = false
		dialogo_aberto = false
