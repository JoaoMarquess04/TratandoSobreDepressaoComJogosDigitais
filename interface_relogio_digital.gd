extends CanvasLayer

signal resolvido

var hora_alvo: int = 0
var minuto_alvo: int = 0

var hora_atual: int = 0
var minuto_atual: int = 0

func _ready():
	visible = false
	$Control/BotaoHoraMais.pressed.connect(_on_hora_mais)
	$Control/BotaoHoraMenos.pressed.connect(_on_hora_menos)
	$Control/BotaoMinutosMais.pressed.connect(_on_minuto_mais)
	$Control/BotaoMinutosMenos.pressed.connect(_on_minuto_menos)
	$Control/Confirmar.pressed.connect(_on_confirmar)
	$Control/Fechar.pressed.connect(fechar)

func iniciar(hora_correta: int, minuto_correto: int):
	hora_alvo = hora_correta
	minuto_alvo = minuto_correto
	hora_atual = 0
	minuto_atual = 0
	atualizar_display()

func _on_hora_mais():
	hora_atual = (hora_atual + 1) % 24
	atualizar_display()

func _on_hora_menos():
	hora_atual = (hora_atual - 1 + 24) % 24
	atualizar_display()

func _on_minuto_mais():
	minuto_atual = (minuto_atual + 5) % 60  # incrementos de 5 em 5
	atualizar_display()

func _on_minuto_menos():
	minuto_atual = (minuto_atual - 5 + 60) % 60
	atualizar_display()

func atualizar_display():
	# formata com zero a esquerda, tipo "08 : 45"
	var texto_hora = str(hora_atual).pad_zeros(2)
	var texto_minuto = str(minuto_atual).pad_zeros(2)
	$Control/Label.text = texto_hora + " : " + texto_minuto

func _on_confirmar():
	if hora_atual == hora_alvo and minuto_atual == minuto_alvo:
		resolvido.emit()
		fechar()
	else:
		print("Horario incorreto, tente novamente")
		# feedback de erro aqui, ex: piscar o Label de vermelho por um instante

func fechar():
	visible = false
	get_tree().paused = false
