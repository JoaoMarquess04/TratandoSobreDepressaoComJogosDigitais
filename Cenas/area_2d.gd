extends Area2D

@export var damage := 10

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("stop_damage"):
		body.stop_damage()
