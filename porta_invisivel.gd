extends StaticBody2D


# parede invisivel: bloqueia a saida ate o radio chamar abrir()
func abrir() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
