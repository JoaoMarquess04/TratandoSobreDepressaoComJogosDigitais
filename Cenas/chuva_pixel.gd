extends Node2D
## Chuva de fundo em um único lote, sem partículas ou colisões.

const QUANTIDADE: int = 48
const PASSO: float = 1.0 / 12.0
var tempo: float = 0.0
var inicio_ms: int = 0
var gotas: Array[Vector4] = []
var linhas := PackedVector2Array()


func _ready() -> void:
	inicio_ms = Time.get_ticks_msec()
	var relogio := Timer.new()
	relogio.wait_time = PASSO
	relogio.timeout.connect(_atualizar_animacao)
	add_child(relogio)
	relogio.start()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1609
	for i in range(QUANTIDADE):
		gotas.append(Vector4(rng.randf(), rng.randf(), rng.randf_range(0.45, 0.8), rng.randi_range(2, 4)))
	linhas.resize(QUANTIDADE * 4)
	get_viewport().size_changed.connect(queue_redraw)
	queue_redraw()


func _atualizar_animacao() -> void:
	tempo = (Time.get_ticks_msec() - inicio_ms) * 0.001
	queue_redraw()


func _draw() -> void:
	var tela: Vector2 = get_viewport_rect().size
	if tela.x <= 0.0 or tela.y <= 0.0:
		return
	var pixel: float = maxf(1.0, roundf(tela.y / 216.0))
	var grade := Vector2(ceilf(tela.x / pixel), ceilf(tela.y / pixel))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(pixel, pixel))
	for i in range(gotas.size()):
		var gota: Vector4 = gotas[i]
		var x: float = floorf(fposmod(gota.x * grade.x - tempo * 13.0, grade.x + 8)) - 4
		var y: float = floorf(fposmod(gota.y * grade.y + tempo * gota.z * grade.y, grade.y + 12)) - 6
		var base: int = i * 4
		# Dois traços verticais produzem uma diagonal em degraus.
		linhas[base] = Vector2(x + 0.5, y)
		linhas[base + 1] = Vector2(x + 0.5, y + gota.w)
		linhas[base + 2] = Vector2(x - 0.5, y + gota.w)
		linhas[base + 3] = Vector2(x - 0.5, y + gota.w + 2)
	if not linhas.is_empty():
		draw_multiline(linhas, Color(0.72, 0.83, 0.88, 0.48), 1.0, false)
