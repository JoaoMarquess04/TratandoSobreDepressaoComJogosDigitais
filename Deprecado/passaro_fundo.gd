extends Node2D
## Silhueta animada; o deslocamento do bando vem do Parallax2D pai.

@export var fase: float = 0.0
var tempo: float = 0.0
const INTERVALO_ANIMACAO: float = 1.0 / 12.0
var acumulado: float = 0.0
var asas := PackedVector2Array([
	Vector2(-9, -3), Vector2(-4, -3), Vector2.ZERO,
	Vector2(4, -3), Vector2(9, -3),
])


func _process(delta: float) -> void:
	tempo = fmod(tempo + delta, TAU * 10.0)
	acumulado += delta
	if acumulado < INTERVALO_ANIMACAO:
		return
	acumulado = fmod(acumulado, INTERVALO_ANIMACAO)
	queue_redraw()


func _draw() -> void:
	var batida: float = sin(tempo * 4.0 + fase)
	var altura: float = sin(tempo * 1.4 + fase) * 2.0
	var ponta: float = -3.0 - batida * 4.0
	asas[0].y = altura + ponta
	asas[1].y = altura - 3
	asas[2].y = altura
	asas[3].y = altura - 3
	asas[4].y = altura + ponta
	draw_polyline(asas, Color(0.16, 0.17, 0.24), 1.5, false)
