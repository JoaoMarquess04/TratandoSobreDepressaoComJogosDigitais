extends Node2D
## Arte desenhada numa grade de pixels inteiros, independente do zoom do jogador.

const CEU: Array[Color] = [
	Color("495b6d"), Color("546779"), Color("62798a"), Color("718898"),
	Color("8096a4"), Color("8fa5b0"), Color("9cb1ba"), Color("aabec4"),
]
var deslocamento: float = 0.0
var passo_parallax: int = -2147483648
var alturas_ilhas := PackedInt32Array([1, 3, 5, 7, 8, 8, 6, 5, 3, 2])


func _ready() -> void:
	var relogio := Timer.new()
	relogio.wait_time = 0.1
	relogio.timeout.connect(_atualizar_parallax)
	add_child(relogio)
	relogio.start()
	get_viewport().size_changed.connect(queue_redraw)
	queue_redraw()


func _atualizar_parallax() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var pixel: float = maxf(1.0, roundf(get_viewport_rect().size.y / 216.0))
	var novo: float = camera.get_screen_center_position().x
	# Só invalida o desenho quando a camada mais rápida avança um pixel.
	var passo: int = int(floorf(novo * 0.18 / pixel))
	if passo == passo_parallax:
		return
	passo_parallax = passo
	deslocamento = novo
	queue_redraw()


func _draw() -> void:
	var tela: Vector2 = get_viewport_rect().size
	if tela.x <= 0.0 or tela.y <= 0.0:
		return
	var pixel: float = maxf(1.0, roundf(tela.y / 216.0))
	var grade := Vector2(ceilf(tela.x / pixel), ceilf(tela.y / pixel))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(pixel, pixel))
	var horizonte: int = int(roundf(grade.y * 0.57))
	# Paleta reduzida e faixas de cor, sem degradê suave ou brilho transparente.
	for i in range(CEU.size()):
		var y: int = int(floorf(float(horizonte * i) / CEU.size()))
		var fim: int = int(ceilf(float(horizonte * (i + 1)) / CEU.size()))
		draw_rect(Rect2(0, y, grade.x, fim - y), CEU[i])
	# Nuvens em blocos, com uma faixa sombreada na base.
	for i in range(7):
		var x: float = floorf(fposmod(grade.x * i * 0.19 - deslocamento * 0.035 / pixel, grade.x + 60) - 30)
		var y: float = roundf(grade.y * (0.12 + (i % 3) * 0.09))
		var largura: float = maxf(26, roundf(grade.x * 0.15))
		draw_rect(Rect2(x, y, largura, 6), Color("728593"))
		draw_rect(Rect2(x + 3, y - 2, largura - 7, 2), Color("728593"))
		draw_rect(Rect2(x + 7, y - 4, maxf(3, largura - 17), 2), Color("728593"))
		draw_rect(Rect2(x + 2, y + 6, largura - 4, 2), Color("5d7182"))
	# Mar em três tons e linha do horizonte nítida.
	draw_rect(Rect2(0, horizonte, grade.x, grade.y - horizonte), Color("5a7788"))
	draw_rect(Rect2(0, horizonte + 16, grade.x, grade.y - horizonte), Color("486879"))
	draw_rect(Rect2(0, horizonte + 48, grade.x, grade.y - horizonte), Color("3c586b"))
	draw_rect(Rect2(0, horizonte, grade.x, 1), Color("9cb5bf"))
	# Ilhas com silhuetas em degraus no lugar de diagonais lisas.
	for i in range(4):
		var x: float = floorf(fposmod(i * grade.x * 0.37 - deslocamento * 0.09 / pixel, grade.x + 74) - 37)
		for j in range(alturas_ilhas.size()):
			draw_rect(Rect2(x + j * 5, horizonte + 2 - alturas_ilhas[j], 5, alturas_ilhas[j]), Color("6d8590"))
	# Ondas frias, sem reflexo solar.
	for i in range(16):
		var x: float = floorf(fposmod(i * 46.0 - deslocamento * 0.18 / pixel, grade.x + 18) - 9)
		var y: float = horizonte + 5 + floorf(fposmod(i * 14.0, maxf(1, grade.y - horizonte - 7)))
		draw_rect(Rect2(x, y, 4 + (i % 4) * 3, 1), Color("91aeb8"))
