extends Node2D
## Bando procedural em pixel art: um nó e um lote de traços horizontais.

@export_range(1, 48) var quantidade: int = 10
@export var semente: int = 27
const PASSO: float = 1.0 / 12.0
var tempo: float = 0.0
var inicio_ms: int = 0
var aves: Array[Vector4] = []
var linhas := PackedVector2Array()


func _ready() -> void:
	inicio_ms = Time.get_ticks_msec()
	var relogio := Timer.new()
	relogio.wait_time = PASSO
	relogio.timeout.connect(_atualizar_animacao)
	add_child(relogio)
	relogio.start()
	var rng := RandomNumberGenerator.new()
	rng.seed = semente
	for i in range(quantidade):
		aves.append(Vector4(rng.randf(), rng.randf_range(0.15, 0.46), rng.randf_range(0.012, 0.035), rng.randf_range(0, TAU)))
	linhas.resize(quantidade * 10)
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
	var camera := get_viewport().get_camera_2d()
	var camera_x: float = camera.get_screen_center_position().x if camera != null else 0.0
	for i in range(aves.size()):
		var ave: Vector4 = aves[i]
		var x: float = floorf(fposmod((ave.x + tempo * ave.z) * grade.x - camera_x * 0.06 / pixel, grade.x + 16) - 8)
		var y: float = floorf(ave.y * grade.y + sin(tempo * 0.8 + ave.w))
		# Três poses de asas; cada ave mantém seu ritmo independente.
		var batida: float = sin(tempo * 4 + ave.w)
		var asa: float = -2.0 if batida > 0.35 else 1.0 if batida < -0.35 else -1.0
		var base: int = i * 10
		linhas[base] = Vector2(x, y + 0.5)
		linhas[base + 1] = Vector2(x + 1, y + 0.5)
		linhas[base + 2] = Vector2(x - 1, y - 0.5)
		linhas[base + 3] = Vector2(x, y - 0.5)
		linhas[base + 4] = Vector2(x + 1, y - 0.5)
		linhas[base + 5] = Vector2(x + 2, y - 0.5)
		linhas[base + 6] = Vector2(x - 3, y + asa + 0.5)
		linhas[base + 7] = Vector2(x - 1, y + asa + 0.5)
		linhas[base + 8] = Vector2(x + 2, y + asa + 0.5)
		linhas[base + 9] = Vector2(x + 4, y + asa + 0.5)
	if not linhas.is_empty():
		draw_multiline(linhas, Color("343349"), 1.0, false)
