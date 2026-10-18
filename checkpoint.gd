extends Area2D

#Checkpoint: quando o player passa, o respawn dele passa a ser aqui
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.respawn_position = body.global_position
