extends Area2D

func _on_body_entered(body):
	print("Algo entrou:", body.name)

	if body.is_in_group("player"):
		print("Jogador detectado!")
		var hud = get_node("/root/Node/CanvasLayer2")
		hud.add_orb()
		queue_free()
