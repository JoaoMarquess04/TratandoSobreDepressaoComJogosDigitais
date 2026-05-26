extends Area2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	# Verifica se o objeto que entrou é um CharacterBody2D
	if body is CharacterBody2D:
		# Troca para a cena desejada !!!!!!!!! 
		get_tree().change_scene_to_file.call_deferred("res://Cenas/NiveisFarol/Nivel-1/NivelAndar1.tscn")
