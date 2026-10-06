extends Node2D
## Placa informativa: o diálogo abre automaticamente ao entrar na área.

var jogador_dentro := false

func _ready() -> void:
	$Label.visible = false
	$TextureRect.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "CharacterBody2D":
		jogador_dentro = true
		$TextureRect.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "CharacterBody2D":
		jogador_dentro = false
		$TextureRect.visible = false
