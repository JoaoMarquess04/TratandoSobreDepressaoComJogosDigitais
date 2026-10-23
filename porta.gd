extends StaticBody2D


@export var textura_aberta: Texture2D

func abrir():
	$Sprite2D.texture = textura_aberta
	$CollisionShape2D.disabled = true
