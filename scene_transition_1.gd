extends Area2D

# @export permite definir o valor da variável pelo Inspetor da cena.
@export var next_scene: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	# Verifica se o objeto que colidiu com a área tem o nome de classe "CharachterBody2D"
	if body is CharacterBody2D:
	# Realiza a troca de cena.
		get_tree().change_scene_to_file.call_deferred(next_scene)
	
