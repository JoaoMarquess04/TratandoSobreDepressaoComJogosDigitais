extends Node2D
## Placa informativa: mostra a caixa do teclado ou a do controle,
## conforme o último dispositivo usado.

static var usando_controle := false   # compartilhada entre todas as placas
var jogador_dentro := false

@onready var caixa_teclado: Control = $TextureRect
@onready var caixa_controle: Control = $TextureRectControle

func _ready() -> void:
	caixa_teclado.visible = false
	caixa_controle.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		usando_controle = false
	elif event is InputEventMouseButton and event.pressed:
		usando_controle = false
	elif event is InputEventJoypadButton and event.pressed:
		usando_controle = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
		usando_controle = true
	else:
		return
	_atualizar()

func _atualizar() -> void:
	if not jogador_dentro:
		return
	caixa_teclado.visible = not usando_controle
	caixa_controle.visible = usando_controle

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		jogador_dentro = true
		_atualizar()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		jogador_dentro = false
		caixa_teclado.visible = false
		caixa_controle.visible = false
