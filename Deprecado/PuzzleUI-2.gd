extends CanvasLayer

# ============================================
# SINAIS
# ============================================

signal puzzle_venceu
signal puzzle_fechado


# ============================================
# CONFIGURAÇÕES (EXPORT)
# ============================================

@export var valor_minimo: int = 1
@export var valor_maximo: int = 9
@export var soma_alvo: int = 15


# ============================================
# ESTADO INTERNO
# ============================================

var numeros: Array[int] = []
var botoes: Array[Button] = []
var puzzle_resolvido: bool = false


# ============================================
# INICIALIZAÇÃO
# ============================================

func _ready() -> void:
	visible = false

	# Guarda os 9 botões em ordem (esquerda -> direita, cima -> baixo)
	# indices:
	# 0 1 2
	# 3 4 5
	# 6 7 8
	botoes = [
		$Control/GridContainer/BotaoNum00,
		$Control/GridContainer/BotaoNum01,
		$Control/GridContainer/BotaoNum02,
		$Control/GridContainer/BotaoNum10,
		$Control/GridContainer/BotaoNum11,
		$Control/GridContainer/BotaoNum12,
		$Control/GridContainer/BotaoNum20,
		$Control/GridContainer/BotaoNum21,
		$Control/GridContainer/BotaoNum22
	]

	for i in range(botoes.size()):
		botoes[i].pressed.connect(_on_numero_clicado.bind(i))

	$Control/BotaoFechar.pressed.connect(_on_fechar_pressionado)


# ============================================
# ABRIR / INICIAR O PUZZLE
# ============================================

func iniciar() -> void:
	puzzle_resolvido = false
	numeros = []
	for i in range(9):
		numeros.append(valor_minimo)

	atualizar_tudo()
	visible = true


# ============================================
# CLIQUE NUM NUMERO -> INCREMENTA (CICLA)
# ============================================

func _on_numero_clicado(indice: int) -> void:
	if puzzle_resolvido:
		return

	numeros[indice] += 1
	if numeros[indice] > valor_maximo:
		numeros[indice] = valor_minimo

	atualizar_tudo()
	verificar_vitoria()


# ============================================
# CALCULA TODAS AS SOMAS (3 LINHAS, 3 COLUNAS, 2 DIAGONAIS)
# ============================================

func calcular_somas() -> Dictionary:
	var linhas: Array[int] = [
		numeros[0] + numeros[1] + numeros[2],
		numeros[3] + numeros[4] + numeros[5],
		numeros[6] + numeros[7] + numeros[8]
	]

	var colunas: Array[int] = [
		numeros[0] + numeros[3] + numeros[6],
		numeros[1] + numeros[4] + numeros[7],
		numeros[2] + numeros[5] + numeros[8]
	]

	var diagonais: Array[int] = [
		numeros[0] + numeros[4] + numeros[8],  # diagonal principal
		numeros[2] + numeros[4] + numeros[6]   # diagonal secundaria
	]

	return {
		"linhas": linhas,
		"colunas": colunas,
		"diagonais": diagonais
	}


# ============================================
# ATUALIZA TEXTO DOS BOTOES E DOS LABELS DE SOMA
# ============================================

func atualizar_tudo() -> void:
	# Atualiza numero exibido em cada botao
	for i in range(botoes.size()):
		botoes[i].text = str(numeros[i])

	var somas: Dictionary = calcular_somas()

	# Labels das linhas (ficam na lateral direita da grade, uma por linha)
	_atualizar_label_soma($Control/LabelSomaLinha0, somas["linhas"][0])
	_atualizar_label_soma($Control/LabelSomaLinha1, somas["linhas"][1])
	_atualizar_label_soma($Control/LabelSomaLinha2, somas["linhas"][2])

	# Labels das colunas (ficam embaixo da grade, uma por coluna)
	_atualizar_label_soma($Control/LabelSomaColuna0, somas["colunas"][0])
	_atualizar_label_soma($Control/LabelSomaColuna1, somas["colunas"][1])
	_atualizar_label_soma($Control/LabelSomaColuna2, somas["colunas"][2])

	# Labels das diagonais (ficam nos cantos ou abaixo de tudo)
	_atualizar_label_soma($Control/LabelSomaDiag0, somas["diagonais"][0])
	_atualizar_label_soma($Control/LabelSomaDiag1, somas["diagonais"][1])


# Aplica o texto e a cor (verde se bateu o alvo, branco/padrao se nao)
func _atualizar_label_soma(label: Label, valor: int) -> void:
	label.text = str(valor)

	if valor == soma_alvo:
		label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))  # verde
	else:
		label.remove_theme_color_override("font_color")  # volta pra cor padrao do tema


# ============================================
# VERIFICA SE TODAS AS 8 SOMAS BATEM COM O ALVO
# ============================================

func verificar_vitoria() -> bool:
	var somas: Dictionary = calcular_somas()

	for s in somas["linhas"]:
		if s != soma_alvo:
			return false
	for s in somas["colunas"]:
		if s != soma_alvo:
			return false
	for s in somas["diagonais"]:
		if s != soma_alvo:
			return false

	# Todas as somas bateram -> vitoria
	_vencer_puzzle()
	return true


func _vencer_puzzle() -> void:
	if puzzle_resolvido:
		return

	puzzle_resolvido = true
	print("Puzzle da matriz resolvido!")

	# Pequeno delay opcional para o jogador ver o ultimo numero certo antes de fechar
	await get_tree().create_timer(0.4).timeout

	puzzle_venceu.emit()
	fechar()


# ============================================
# FECHAR O CANVAS
# ============================================

func _on_fechar_pressionado() -> void:
	fechar()
	puzzle_fechado.emit()


func fechar() -> void:
	visible = false
	get_tree().paused = false
