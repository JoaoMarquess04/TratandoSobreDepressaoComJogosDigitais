extends StaticBody2D

@export var textura_fechada: Texture2D
@export var textura_aberta: Texture2D

func _ready():
	$Sprite2D.texture = textura_fechada
	$CollisionShape2D.disabled = false

func abrir():
	$Sprite2D.texture = textura_aberta
	$CollisionShape2D.disabled = true
